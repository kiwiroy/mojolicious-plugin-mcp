use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use MCP::Client;
use MCP::Constants qw(PROTOCOL_VERSION);

use Mojolicious::Lite;
use Mojo::File qw(curfile);
use lib "@{[ curfile->sibling('lib')]}";

plugin 'MCP';

get '/' => sub {
  my $c = shift;
  $c->render(text => 'Hello Mojo!');
};

any '/mcp' => app->mcp->to_action;


my $t = Test::Mojo->with_roles('+MCP')->new;

subtest 'Server responds' => sub {
  $t->get_ok('/')->status_is(200)->content_is('Hello Mojo!');
  $t->get_ok('/mcp')->status_is(405)->json_is({error => "Method not allowed"});
  $t->mcp_client_init_ok('MCP Server', $Mojolicious::Plugin::MCP::VERSION);
};

done_testing();
