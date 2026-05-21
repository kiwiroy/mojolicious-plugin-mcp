use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use MCP::Client;
use MCP::Constants qw(PROTOCOL_VERSION);
use Mojo::JSON     qw(to_json);

use Mojolicious::Lite -signatures;

eval {
  # Negative::Resource::Fail inherits from MCP::Tool!
  plugin 'MCP' => {namespace => 'Negative'};
};

like $@, qr/^Failed to load MCP 'Resource' module 'Negative::Resource::Fail'/,
  'Proper error is thrown when a resource fails to load';

done_testing();
