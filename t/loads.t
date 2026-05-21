use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use MCP::Client;
use MCP::Constants qw(PROTOCOL_VERSION);
use Mojo::JSON     qw(to_json);

use Mojolicious::Lite -signatures;
use Mojo::File qw(curfile);
use lib "@{[ curfile->sibling('lib')]}";

plugin 'MCP' => {mcp_helper => 'mcp_server', namespace => 'Test', name => 'Test MCP Server', version => '3.14'};

app->helper(
  ask => sub ($c, $question) {
    return "You asked: $question";
  }
);

app->helper(
  echo => sub ($c, $msg) {
    return "Echo: $msg";
  }
);

get '/' => sub {
  my $c = shift;
  $c->render(text => 'Hello Mojo!');
};

any '/mcp' => app->mcp_server->to_action;

my $t = Test::Mojo->new;

subtest 'Server responds' => sub {
  $t->get_ok('/')->status_is(200)->content_is('Hello Mojo!');
  $t->get_ok('/mcp')->status_is(405)->json_is({error => "Method not allowed"});

  my $client = MCP::Client->new(ua => $t->ua, url => $t->ua->server->url->path('/mcp'));
  my $init   = $client->initialize_session;
  $t->test(
    is_deeply => $init,
    {
      protocolVersion => PROTOCOL_VERSION,
      serverInfo      => {name    => 'Test MCP Server', version => '3.14'},
      capabilities    => {prompts => {}, resources => {}, tools => {}},
    },
    'Initialization response is correct'
  );

  my $result = $client->list_tools;
  $t->test(
    is_deeply => $result,
    {
      tools => [{
        description => 'echo',
        inputSchema => to_json({
          type       => 'object',
          properties => {msg => {description => 'Message to echo', type => 'string'}},
          required   => ['msg'],
        }),
        name         => 'echo',
        outputSchema => to_json({
          type       => 'object',
          properties => {msg => {description => 'Echoed message', type => 'string'}},
          required   => ['msg'],
        }),
      }],
    },
    'Initialization response is correct'
  );

  $result = $client->list_resources;
  $t->test(
    is_deeply => $result,
    {
      resources => [{
        'description' => 'Tail a file',
        'mimeType'    => 'text/plain',
        'name'        => 'tail',
        'uri'         => 'file:///var/log/syslog'
      }]
    },
    'Initialization response is correct'
  );

  $result = $client->list_prompts;
  $t->test(
    is_deeply => $result,
    {
      'prompts' => [{
        'arguments'   => [{name => 'question', description => 'The question to ask', required => 1}],
        'description' => 'Ask a question',
        'name'        => 'ask'
      }]
    },
    'Initialization response is correct'
  );
};

subtest 'Echo tool' => sub {
  my $client = MCP::Client->new(ua => $t->ua, url => $t->ua->server->url->path('/mcp'));
  my $init   = $client->initialize_session;
  $t->test(ok => $init, 'Session initialized successfully');
  my $result = $client->call_tool('echo', {msg => 'Hello, world!'});
  $t->test(
    'is_deeply',
    $result,
    {
      'content' => [{'text' => 'Echo: Hello, world!', 'type' => 'text'}],
      'isError' => bless(do { \(my $o = 0) }, 'JSON::PP::Boolean')
    },
    'Echo tool response is correct'
  );
};

subtest "Tail resource" => sub {
  my $client = MCP::Client->new(ua => $t->ua, url => $t->ua->server->url->path('/mcp'));
  my $init   = $client->initialize_session;
  $t->test(ok => $init, 'Session initialized successfully');
  my $result           = $client->read_resource('file:///var/log/syslog');
  my $expected_content = do { local (@ARGV, $/) = ('t/lib/Test/Resource/Tail.pm'); <> };
  $t->test(
    'is_deeply', $result,
    {contents => [{'text' => $expected_content, 'mimeType' => 'text/plain', uri => 'file:///var/log/syslog'},],},
    'Tail resource response is correct'
  );
};

subtest 'Ask prompt' => sub {
  my $client = MCP::Client->new(ua => $t->ua, url => $t->ua->server->url->path('/mcp'));
  my $init   = $client->initialize_session;
  $t->test(ok => $init, 'Session initialized successfully');
  my $result = $client->get_prompt('ask', {question => 'What is your name?'});
  $t->test(
    is_deeply => $result,
    {'messages' => [{'content' => {'text' => 'You asked: What is your name?', 'type' => 'text'}, 'role' => 'user'}]},
    'Ask prompt response is correct'
  );
};

done_testing();
