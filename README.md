# NAME

Mojolicious::Plugin::MCP - Mojolicious Plugin to use with Model Context Protocol (MCP)

# SYNOPSIS

    # Mojolicious
    $app->plugin(MCP => \%config);

    # Mojolicious::Lite
    plugin MCP => \%config;

# DESCRIPTION

[Mojolicious::Plugin::MCP](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AMCP) is a [Mojolicious](https://metacpan.org/pod/Mojolicious) plugin.

# ATTRIBUTES

[Mojolicious::Plugin::MCP](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AMCP) inherits all attributes from [Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious%3A%3APlugin) and implements the following new ones.

## mcp\_primitives

    my $primitives = $plugin->mcp_primitives;

A hashref mapping MCP primitive types (Resource, Prompt, Tool) to their corresponding base classes ([MCP::Resource](https://metacpan.org/pod/MCP%3A%3AResource),
[MCP::Prompt](https://metacpan.org/pod/MCP%3A%3APrompt), [MCP::Tool](https://metacpan.org/pod/MCP%3A%3ATool)). This is used internally to determine which modules to load and how to validate them.

# CONFIGURATION

[Mojolicious::Plugin::MCP](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AMCP) can be configured by passing a hashref of options when registering the plugin. The
following options are available:

## namespace

    plugin MCP => {namespace => 'MyApp::MCP'};

The namespace to search for MCP Primitives (Prompts, Tools, and Resources). The plugin will automatically load any
modules in this namespace that inherit from the corresponding MCP base classes ([MCP::Prompt](https://metacpan.org/pod/MCP%3A%3APrompt), [MCP::Tool](https://metacpan.org/pod/MCP%3A%3ATool),
[MCP::Resource](https://metacpan.org/pod/MCP%3A%3AResource)) and register them with the MCP Server.

The default is `Mojolicious::Plugin::MCP`.

## name

    plugin MCP => {name => 'My MCP Server'};

The name of the MCP Server, which is returned in the serverInfo of the initialization response.

The default is `MCP Server`.

## version

    plugin MCP => {version => '1.0'};

The version of the MCP Server, which is returned in the serverInfo of the initialization response.

The default is `0.01` (The `$VERSION` of this module).

## mcp\_helper

    plugin MCP => {mcp_helper => 'my_mcp'};

The name of the helper method that returns the MCP Server instance. This can be used to avoid conflicts with other
plugins or helpers.

The default is `mcp` as per ["mcp"](#mcp).

# HELPERS

[Mojolicious::Plugin::MCP](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AMCP) provides the following helpers:

## mcp

    my $server = $c->mcp;

Returns the [MCP::Server](https://metacpan.org/pod/MCP%3A%3AServer) instance, which can be used to subscribe to [events](https://metacpan.org/pod/MCP%3A%3AServer#EVENTS) or
register further Prompts, Tools, and Resources. The name of this helper can be customized using the
["mcp\_helper"](#mcp_helper) configuration option.

# METHODS

[Mojolicious::Plugin::MCP](https://metacpan.org/pod/Mojolicious%3A%3APlugin%3A%3AMCP) inherits all methods from [Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious%3A%3APlugin) and implements the following new ones.

## register

    $plugin->register(Mojolicious->new, \%config);

Register plugin in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

# SEE ALSO

[MCP](https://metacpan.org/pod/MCP), [Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious%3A%3AGuides), [https://mojolicious.org](https://mojolicious.org).
