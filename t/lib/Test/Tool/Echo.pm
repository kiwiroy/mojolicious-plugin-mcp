package Test::Tool::Echo;

use Mojo::Base 'MCP::Tool', -signatures;
use Mojo::JSON   qw(j);
use Mojo::Loader qw(data_section);

has description   => 'echo';
has code          => sub { return \&echo };
has input_schema  => sub ($self) { return j j(data_section __PACKAGE__, 'input_schema.json') };
has name          => 'echo';
has output_schema => sub ($self) { return j j(data_section __PACKAGE__, 'output_schema.json') };

sub echo ($tool, $input) {
  return $tool->context->controller->echo($input->{msg});
}

1;
__DATA__
@@ input_schema.json
{
  "type": "object",
  "properties": {
    "msg": {
      "description": "Message to echo",
      "type": "string"
    }
  },
  "required": ["msg"]
}
@@ output_schema.json
{
  "type": "object",
  "properties": {
    "msg": {
      "description": "Echoed message",
      "type": "string"
    }
  },
  "required": ["msg"]
}
