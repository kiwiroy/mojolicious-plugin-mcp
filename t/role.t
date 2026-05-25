use Test::More;
use Test::Mojo;
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

subtest 'MCP test role' => sub {
  my $t = Test::Mojo->with_roles('+MCP')->new;
  ok $t->can('mcp_client_init_ok'),    'Test::Mojo with MCP role can initialize client';
  ok $t->can('mcp_list_tools_ok'),     'Test::Mojo with MCP role can list tools';
  ok $t->can('mcp_list_resources_ok'), 'Test::Mojo with MCP role can list resources';
  ok $t->can('mcp_list_prompts_ok'),   'Test::Mojo with MCP role can list prompts';

  $t->mcp_path('/custom_mcp_path');
  is $t->mcp_path, '/custom_mcp_path', 'MCP path can be set and retrieved';
  is $t->mcp_res,  undef,              'MCP response attribute is initialized to undef';
  subtest 'JSON tests' => sub {
    local $t->{mcp_res} = {foo => 'bar', baz => [1, 2, 3]};
    $t->mcp_json_is('/foo', 'bar')
      ->mcp_json_is({foo => 'bar', baz => [1, 2, 3]})
      ->mcp_json_is('/baz/1', 2)
      ->mcp_json_is('/nonexistent', undef, 'Nonexistent path returns undef')
      ->mcp_json_like('/foo', qr/^ba/, 'JSON path matches regex')
      ->mcp_json_unlike('/foo', qr/^qu/, 'JSON path does not match regex');
  };
};

done_testing();
