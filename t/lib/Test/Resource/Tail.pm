package Test::Resource::Tail;
use Mojo::Base 'MCP::Resource', -signatures;
use Mojo::Loader qw(data_section);

has description => 'Tail a file';
has code        => sub { return \&tail };
has mime_type   => 'text/plain';
has name        => 'tail';
has uri         => 'file:///var/log/syslog';

sub tail ($resource) {
  my $file = $resource->context->controller->app->home->child(qw(lib Test Resource Tail.pm));
  return $file->slurp;
}

1;
