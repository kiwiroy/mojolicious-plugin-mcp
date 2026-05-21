use 5.020;
use strict;
use warnings;
use utf8;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::MCP',
  VERSION_FROM => 'lib/Mojolicious/Plugin/MCP.pm',
  ABSTRACT     => 'Mojolicious Plugin to use with Model Context Protocol (MCP)',
  AUTHOR       => 'Roy Storey <kiwiroy@cpan.org>',
  PREREQ_PM    => {'Mojolicious' => '9.45', 'MCP' => '0.10', 'Role::Tiny' => '2.002005'},
  META_MERGE   => {
    dynamic_config => 0,
    'meta-spec'    => {version   => 2},
    no_index       => {directory => ['examples', 't']},
    prereqs        => {runtime   => {requires => {perl => '5.020'}}},
    resources      => {
      bugtracker => {web => 'https://github.com/kiwiroy/mojolicious-plugin-mcp/issues'},
      homepage   => 'https://mojolicious.org',
      repository => {
        type => 'git',
        url  => 'https://github.com/kiwiroy/mojolicious-plugin-mcp.git',
        web  => 'https://github.com/kiwiroy/mojolicious-plugin-mcp',
      },
    },
  },
  test => {TESTS => 't/*.t'}
);
