package Test::Mojo::Role::MCP;

use Mojo::Base -role, -signatures;
use MCP::Client;
use MCP::Constants qw(PROTOCOL_VERSION);

requires 'test';

has mcp_client => sub ($self) {
  return MCP::Client->new(ua => $self->ua, url => $self->ua->server->url->path($self->mcp_path));
};
has mcp_path => '/mcp';
has mcp_res  => undef;

sub mcp_call_tool_ok ($self, $tool, $args, $desc = 'MCP Client called tool successfully') {
  my $client = $self->_client_init;
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  return $self->mcp_res($client->call_tool($tool, $args))->test(is => ref $self->mcp_res, 'HASH', $desc);
}

sub mcp_client_init_ok ($self, $name, $version, $desc = 'MCP Client initialized successfully') {
  my $init = $self->{initialised}{$self->_client_init};
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  return $self->test('fail', 'MCP Client failed to initialize session') unless $init;
  return $self->test(
    is_deeply => $init,
    {
      protocolVersion => PROTOCOL_VERSION,
      serverInfo      => {name    => $name, version   => $version},
      capabilities    => {prompts => {},    resources => {}, tools => {}},
    },
    $desc
  );
}

sub mcp_get_prompt_ok ($self, $prompt, $args, $desc = 'MCP Client got prompt successfully') {
  my $client = $self->_client_init;
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  return $self->mcp_res($client->get_prompt($prompt, $args))->test(is => ref $self->mcp_res, 'HASH', $desc);
}

sub mcp_list_prompts_ok ($self, $desc = 'MCP Client listed prompts successfully') {
  my $client = $self->_client_init;
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  return $self->mcp_res($client->list_prompts)->test(is => ref $self->mcp_res, 'HASH', $desc);
}

sub mcp_list_resources_ok ($self, $desc = 'MCP Client listed resources successfully') {
  my $client = $self->_client_init;
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  return $self->mcp_res($client->list_resources)->test(is => ref $self->mcp_res, 'HASH', $desc);
}

sub mcp_list_tools_ok ($self, $desc = 'MCP Client listed tools successfully') {
  my $client = $self->_client_init;
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  return $self->mcp_res($client->list_tools)->test(is => ref $self->mcp_res, 'HASH', $desc);
}

sub mcp_json_is ($self, $expect, $desc = 'MCP Client response matches expected') {
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  return $self->test(is_deeply => $self->mcp_res, $expect, $desc);
}

sub mcp_read_resource_ok ($self, $uri, $desc = 'MCP Client read resource successfully') {
  my $client = $self->_client_init;
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  return $self->mcp_res($client->read_resource($uri))->test(is => ref $self->mcp_res, 'HASH', $desc);
}

sub _client_init ($self) {
  my $client = $self->mcp_client;
  $self->{initialised}{$client} ||= $client->initialize_session;
  delete $self->{mcp_res};
  return $client;
}

1;

=encoding utf8

=head1 NAME

Test::Mojo::Role::MCP - Role for testing MCP Servers with Test::Mojo

=head1 DESCRIPTION

L<Test::Mojo::Role::MCP> is a role for L<Test::Mojo> that provides helper methods for testing MCP Servers. It includes
methods for initializing the MCP Client and listing prompts, resources, and tools.

=head1 ATTRIBUTES

L<Test::Mojo::Role::MCP> composes the following attributes:

=head2 mcp_client

  my $client = $test->mcp_client;

Returns an instance of L<MCP::Client> initialized with the test's user agent and the MCP endpoint.

=head2 mcp_path

  my $path = $test->mcp_path;

The path to the MCP endpoint. Defaults to C</mcp>.

=head2 mcp_res

  my $response = $test->mcp_res;

Stores the response of the last MCP Client operation for inspection in tests.

=head1 METHODS

L<Test::Mojo::Role::MCP> composes the following methods:

=head2 mcp_call_tool_ok

  $test->mcp_call_tool_ok($tool, $args, $desc);

Calls a tool on the MCP Server with the given arguments and checks that the response is a hash reference.

=head2 mcp_client_init_ok

  $test->mcp_client_init_ok($name, $version, $desc);

Initializes the MCP Client and checks that the response matches the expected server name and version.

=head2 mcp_get_prompt_ok

  $test->mcp_get_prompt_ok($prompt, $args, $desc);

Gets a prompt from the MCP Server with the given arguments and checks that the response is a hash reference.

=head2 mcp_list_prompts_ok

  $test->mcp_list_prompts_ok($desc);

Lists the prompts available from the MCP Server and checks that the response is a hash reference.

=head2 mcp_list_resources_ok

  $test->mcp_list_resources_ok($desc);

Lists the resources available from the MCP Server and checks that the response is a hash reference.

=head2 mcp_list_tools_ok

  $test->mcp_list_tools_ok($desc);

Lists the tools available from the MCP Server and checks that the response is a hash reference.

=head2 mcp_json_is

  $test->mcp_json_is($expect, $desc);

Checks that the last MCP Client response matches the expected data structure.

=head2 mcp_read_resource_ok

  $test->mcp_read_resource_ok($uri, $desc);

Reads a resource from the MCP Server with the given URI and checks that the response is a hash reference.

=cut
