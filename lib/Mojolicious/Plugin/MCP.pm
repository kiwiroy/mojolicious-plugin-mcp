package Mojolicious::Plugin::MCP;

use Mojo::Base 'Mojolicious::Plugin', -signatures;
use Mojo::Loader qw(find_modules find_packages load_class);
use MCP::Server;

our $VERSION = '0.03';

has mcp_primitives => sub {
  +{map { $_ => "MCP::$_" } qw(Resource Prompt Tool)};
};

sub register ($self, $app, $config) {
  $config->{name}      ||= 'MCP Server';
  $config->{version}   ||= $VERSION;
  $config->{namespace} ||= __PACKAGE__;

  my $server = MCP::Server->new(name => $config->{name}, version => $config->{version});

  $app->helper(($config->{mcp_helper} ||= 'mcp') => sub { return $server });

  $self->_warmup_mcp($server, $config->{namespace});
}

sub _warmup_primitive ($module, $primitive, $fatal) {
  return $module->isa($primitive) ? $module : undef unless my $e = load_class $module;
  $fatal && ref $e ? die $e : return undef;
}

sub _warmup_mcp ($self, $server, $namespace) {
  for my $primitive (keys $self->mcp_primitives->%*) {
    my $method        = $server->can(lc $primitive) or die "MCP Server does not have method '$primitive'";
    my $sub_namespace = join '::', $namespace, $primitive;
    my $class         = $self->mcp_primitives->{$primitive};
    for my $module (find_modules($sub_namespace), find_packages($sub_namespace)) {
      _warmup_primitive($module, $class, 1) or die "Failed to load MCP '$primitive' module '$module'";
      $server->$method($module->with_roles('Mojolicious::Plugin::MCP::Role::Spec')->new->to_spec());
    }
  }
  return $self;
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::MCP - Mojolicious Plugin to use with Model Context Protocol (MCP)

=head1 SYNOPSIS

  # Mojolicious
  $app->plugin(MCP => \%config);

  # Mojolicious::Lite
  plugin MCP => \%config;

=head1 DESCRIPTION

L<Mojolicious::Plugin::MCP> is a L<Mojolicious> plugin.

=head1 ATTRIBUTES

L<Mojolicious::Plugin::MCP> inherits all attributes from L<Mojolicious::Plugin> and implements the following new ones.

=head2 mcp_primitives

  my $primitives = $plugin->mcp_primitives;

A hashref mapping MCP primitive types (Resource, Prompt, Tool) to their corresponding base classes (L<MCP::Resource>,
L<MCP::Prompt>, L<MCP::Tool>). This is used internally to determine which modules to load and how to validate them.

=head1 CONFIGURATION

L<Mojolicious::Plugin::MCP> can be configured by passing a hashref of options when registering the plugin. The
following options are available:

=head2 namespace

  plugin MCP => {namespace => 'MyApp::MCP'};

The namespace to search for MCP Primitives (Prompts, Tools, and Resources). The plugin will automatically load any
modules in this namespace that inherit from the corresponding MCP base classes (L<MCP::Prompt>, L<MCP::Tool>,
L<MCP::Resource>) and register them with the MCP Server.

The default is C<Mojolicious::Plugin::MCP>.

=head2 name

  plugin MCP => {name => 'My MCP Server'};

The name of the MCP Server, which is returned in the serverInfo of the initialization response.

The default is C<MCP Server>.

=head2 version

  plugin MCP => {version => '1.0'};

The version of the MCP Server, which is returned in the serverInfo of the initialization response.

The default is C<0.01> (The C<$VERSION> of this module).

=head2 mcp_helper

  plugin MCP => {mcp_helper => 'my_mcp'};

The name of the helper method that returns the MCP Server instance. This can be used to avoid conflicts with other
plugins or helpers.

The default is C<mcp> as per L</"mcp">.

=head1 HELPERS

L<Mojolicious::Plugin::MCP> provides the following helpers:

=head2 mcp

  my $server = $c->mcp;

Returns the L<MCP::Server> instance, which can be used to subscribe to L<events|MCP::Server/"EVENTS"> or
register further Prompts, Tools, and Resources. The name of this helper can be customized using the
L</"mcp_helper"> configuration option.

=head1 METHODS

L<Mojolicious::Plugin::MCP> inherits all methods from L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new, \%config);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<MCP>, L<Mojolicious>, L<Mojolicious::Guides>, L<https://mojolicious.org>.

=cut
