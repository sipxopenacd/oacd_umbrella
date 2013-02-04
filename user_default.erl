-module(user_default).

-include("call.hrl").
-include("queue.hrl").
-include("agent.hrl").

-compile([export_all]).

rld() ->
	reloader:reload_modules(reloader:all_changed()).
