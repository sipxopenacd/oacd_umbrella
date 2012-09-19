Project Overview
================

OpenACD is an opensource project aimed at providing a distributed, fault
tolerant contact/call center platform. It's implemented in
[Erlang](http://erlang.org), uses [Dojo](http://dojotoolkit.org) for
its web UI and integrates tightly with [FreeSWITCH](http://freeswitch.org)
for its VoIP components. The sister project
[gen_smtp](http://github.com/Vagabond/gen_smtp) is used for email support.

Feature Highlights
==================

+ Skill based routing
+ Priority and unified queueing
+ Web-based administration and agent interaction
+ Supervisory interface for managing agents/call flow
+ Support for handling voice calls (inbound and outbound), voicemails and emails
+ Detailed CDRs and agent state recording
+ Extensible architecture for new media types, data collection, and agent interaction

Participants
============

Development is sponsored by [KGB](http://kgb.com) and
the 2 main developers are:

+ Andrew Thompson (andrew AT hijacked.us)
+ Micah Warren (micahw AT lordnull.com)

Other contributions are welcome.

You can also (possibly) get help on IRC via #openacd on FreeNode.

A mailinglist also exists at http://groups.google.com/group/openacd/

Contributing
============

If you'd like to contribute - simply make a fork on github, and once you've got
some changes you like reviewed, send a pull request or email to either of the
main developers. We'll review the changes and either include them or let you
know why not. Also feel free to contribute documentation, translations or report bugs.

Project Status
==============

OpenACD current exists in two states:  version 1.0 which features all the
above, and version 2.0, which adds multi-channel, and improved plugin 
support.  For the stable version 1.0, use the 'v1' branch.  Master is 
version 2, and is in heavy development.

There are also two branches to help when developing plugins:
embeddable_build and embeddable_build_v1.  They correspond to master and
v1 respectively.  When developing a plugin using rebar to build, using
the embeddable_build and embeddable_build_v1 will ensure OpenACD builds 
properly and gives the developer no trouble.

The OpenACD developers are working with [eZuce](http://www.ezuce.com) and 
[KGB](http://kgb.com) to integrate OpenACD as the new sipXecs ACD.

Plugin Development
==================

Project structure
-----------------

OpenACD is divided into the core project and custom plugins. Plugins are erlang applications managed using the [rebar](https://github.com/basho/rebar) build tool. Plugins are usually developed to add new data exporters, media types, or agent endpoints to OpenACD.

- oacd_core
 '- src
 '- include
- oacd_plugins
 '- oacd_plugin1
   '- src
 '- oacd_plugin2
   '- src

Setup for plugin development
----------------------------

### Getting OpenACD core

To start working on OpenACD you need to install Erlang R14B or later and rebar. You can download the OpenACD project from its git repository (currently [oacd_umbrella](https://github.com/dannaaduna/oacd_umbrella)). [oacd_core](https://github.com/dannaaduna/oacd_core) is included in the project as a git submodule.

```sh
$ git clone https://github.com/OpenACD/OpenACD
$ cd OpenACD; git submodule init; git submodule update
```

### Creating a new plugin

To create a new plugin, you should add a new rebar application under the oacd_plugins directory.

```sh
$ mkdir -p oacd_plugins/oacd_plugin_new
$ rebar create-app appid=oacd_plugin1
```
(To be replaced by ./oacd-plugins add oacd_plugin_new.)

You can include header files from oacd_core using the following line:
```sh
-include_lib("oacd_core/include/log.hrl").
```

### Adding an existing plugin

You can also add an existing plugin by specifying its name and git repository.

```sh
$ ./oacd-plugins add oacd_plugin_existing <git repo>
```

### Enabling plugins

After creating or adding plugins, you should also enable them.

```sh
$ ./oacd-plugins enable oacd_plugin_new
$ ./oacd-plugins enable oacd_plugin_existing
```

### Compiling
Running make on OpenACD compiles oacd_core and all the plugins under oacd_plugins.

### Starting oacd_core and plugins
Run the openacd script to start oacd_core and all enabled plugins.

```sh
$ ./openacd
```

More Info
=========

More information can be found on the
[github wiki](http://wiki.github.com/OpenACD/OpenACD/).
Please feel free to contribute
additional information on the wiki if you have it.
