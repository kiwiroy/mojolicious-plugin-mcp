use Test::More;
use Mojo::Base -strict;
use Role::Tiny qw(does_role);
use Mojo::File qw(curfile);
use lib "@{[ curfile->sibling('lib')]}";

package NoInheritance {
  use Mojo::Base -base;
  has description => 'No inheritance';
  has code        => sub {
    return sub {1}
  };
  has name => 'no_inheritance';
};

subtest 'Spec role applies' => sub {
  ok eval { require Test::Resource::Tail; 1; }, 'Test::Resource::Tail loads';
  ok eval { require Test::Tool::Echo;     1; }, 'Test::Tool::Echo loads';
  ok eval { require Test::Prompt::Ask;    1; }, 'Test::Prompt::Ask loads';

  my $resource = Test::Resource::Tail->with_roles('Mojolicious::Plugin::MCP::Role::Spec')->new;
  is Role::Tiny::does_role($resource, 'Mojolicious::Plugin::MCP::Role::Spec'), 1, 'Resource does role';
  ok $resource->can('to_spec');
  my $spec = {$resource->to_spec};
  is_deeply [sort keys %$spec], [qw(code description mime_type name uri)], 'Resource spec has correct keys';
  is $resource->description, 'Tail a file',            'Resource object has correct description';
  is $resource->name,        'tail',                   'Resource object has correct name';
  is $resource->mime_type,   'text/plain',             'Resource object has correct mime_type';
  is $resource->uri,         'file:///var/log/syslog', 'Resource object has correct uri';
  is $spec->{description},   'Tail a file',            'Resource spec has correct description';
  is $spec->{name},          'tail',                   'Resource spec has correct name';
  is $spec->{mime_type},     'text/plain',             'Resource spec has correct mime_type';
  is $spec->{uri},           'file:///var/log/syslog', 'Resource spec has correct uri';

  my $tool = Test::Tool::Echo->with_roles('Mojolicious::Plugin::MCP::Role::Spec')->new;
  is Role::Tiny::does_role($tool, 'Mojolicious::Plugin::MCP::Role::Spec'), 1, 'Tool does role';
  ok $tool->can('to_spec');
  $spec = {$tool->to_spec};
  is_deeply [sort keys %$spec], [qw(code description input_schema name output_schema)], 'Tool spec has correct keys';
  is $spec->{description}, 'echo', 'Tool spec has correct description';
  is $spec->{name},        'echo', 'Tool spec has correct name';
  is $tool->description,   'echo', 'Tool object has correct description';
  is $tool->name,          'echo', 'Tool object has correct name';

  my $prompt = Test::Prompt::Ask->with_roles('Mojolicious::Plugin::MCP::Role::Spec')->new;
  is Role::Tiny::does_role($prompt, 'Mojolicious::Plugin::MCP::Role::Spec'), 1, 'Prompt does role';
  ok $prompt->can('to_spec');
  $spec = {$prompt->to_spec};
  is_deeply [sort keys %$spec], [qw(arguments code description name)], 'Prompt spec has correct keys';
  is $spec->{description}, 'Ask a question', 'Prompt spec has correct description';
  is $spec->{name},        'ask',            'Prompt spec has correct name';
  is $prompt->description, 'Ask a question', 'Prompt object has correct description';
  is $prompt->name,        'ask',            'Prompt object has correct name';

  my $no_inheritance = NoInheritance->with_roles('Mojolicious::Plugin::MCP::Role::Spec')->new;
  is Role::Tiny::does_role($no_inheritance, 'Mojolicious::Plugin::MCP::Role::Spec'), 1, 'NoInheritance does role';
  ok $no_inheritance->can('to_spec');
  $spec = {$no_inheritance->to_spec};
  is_deeply [sort keys %$spec], [], 'NoInheritance spec has no keys';
};

done_testing();
