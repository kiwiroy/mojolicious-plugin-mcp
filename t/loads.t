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

my $t = Test::Mojo->with_roles('+MCP')->new;

subtest 'Server responds' => sub {
  $t->get_ok('/')->status_is(200)->content_is('Hello Mojo!');
  $t->get_ok('/mcp')->status_is(405)->json_is({error => "Method not allowed"});

  $t->mcp_client_init_ok('Test MCP Server', '3.14')->mcp_list_tools_ok->mcp_json_is({
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
  });

  $t->mcp_list_resources_ok->mcp_json_is(
    {
      resources => [{
        'description' => 'Tail a file',
        'mimeType'    => 'text/plain',
        'name'        => 'tail',
        'uri'         => 'file:///var/log/syslog'
      }]
    },
  );

  $t->mcp_list_prompts_ok->mcp_json_is({
    'prompts' => [{
      'arguments'   => [{name => 'question', description => 'The question to ask', required => 1}],
      'description' => 'Ask a question',
      'name'        => 'ask'
    }]
  });
};

subtest 'Echo tool' => sub {
  $t->mcp_call_tool_ok('echo', {msg => 'Hello, world!'})->mcp_json_is({
    'content' => [{'text' => 'Echo: Hello, world!', 'type' => 'text'}],
    'isError' => bless(do { \(my $o = 0) }, 'JSON::PP::Boolean')
  });
};

subtest "Tail resource" => sub {
  my $expected_content = do { local (@ARGV, $/) = ('t/lib/Test/Resource/Tail.pm'); <> };
  $t->mcp_read_resource_ok('file:///var/log/syslog')
    ->mcp_json_is('/contents/0/uri', 'file:///var/log/syslog')
    ->mcp_json_is(
    {contents => [{'text' => $expected_content, 'mimeType' => 'text/plain', uri => 'file:///var/log/syslog'},],});
};

subtest 'Ask prompt' => sub {
  $t->mcp_get_prompt_ok('ask', {question => 'What is your name?'})
    ->mcp_json_is(
    {'messages' => [{'content' => {'text' => 'You asked: What is your name?', 'type' => 'text'}, 'role' => 'user'}]});
};

done_testing();
