package Mojolicious::Plugin::MCP::Role::Spec;

use Mojo::Base -role, -signatures;

requires qw(code description name);

sub to_spec ($self) {
  return (map { $_ => $self->$_ } qw(code description name arguments))                  if $self->isa('MCP::Prompt');
  return (map { $_ => $self->$_ } qw(code description name input_schema output_schema)) if $self->isa('MCP::Tool');
  return (map { $_ => $self->$_ } qw(code description name mime_type uri))              if $self->isa('MCP::Resource');
  return ();
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::MCP::Role::Spec - Role for MCP Specs

=head1 SYNOPSIS

  package My::Prompt {
    use Mojo::Base 'MCP::Prompt', -signatures;
    use Role::Tiny::With;
    with 'Mojolicious::Plugin::MCP::Role::Spec';
  };

Or

  $prompt = My::SQLPrompt->with_roles('Mojolicious::Plugin::MCP::Role::Spec')->new;
  
=head1 DESCRIPTION

This role defines the required attributes and methods for MCP Specs, which are used to define Prompts, Tools, and Resources in the MCP Server.

=head1 METHODS

L<Mojolicious::Plugin::MCP::Role::Spec> composes the following methods:

=head2 to_spec

  my $spec = $spec_object->to_spec;

Returns an array representation of the spec, with keys depending on the primitive of spec (Prompt, Tool, or Resource).

=head1 SEE ALSO

L<Mojolicious::Plugin::MCP>, L<MCP::Prompt>, L<MCP::Tool>, L<MCP::Resource>, L<MCP::Primitive>, L<Role::Tiny>

=cut
