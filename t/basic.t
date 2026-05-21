use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use MCP::Client;
use MCP::Constants qw(PROTOCOL_VERSION);

use Mojolicious::Lite;

plugin 'MCP';

get '/' => sub {
  my $c = shift;
  $c->render(text => 'Hello Mojo!');
};

any '/mcp' => app->mcp->to_action;


my $t = Test::Mojo->new;

subtest 'Server responds' => sub {
  $t->get_ok('/')->status_is(200)->content_is('Hello Mojo!');
  $t->get_ok('/mcp')->status_is(405)->json_is({error => "Method not allowed"});
  my $client = MCP::Client->new(ua => $t->ua, url => $t->ua->server->url->path('/mcp'));
  my $result = $client->initialize_session;
  $t->test(
    'is_deeply',
    $result,
    {
      protocolVersion => PROTOCOL_VERSION,
      serverInfo      => {name    => 'MCP Server', version => $Mojolicious::Plugin::MCP::VERSION},
      capabilities    => {prompts => {}, resources => {}, tools => {}},
    },
    'Initialization response is correct'
  );
};

done_testing();
