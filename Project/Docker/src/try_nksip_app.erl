%%%-------------------------------------------------------------------
%% @doc try_nksip public API
%% @end
%%%-------------------------------------------------------------------

-module(try_nksip_app).

-behaviour(application).

-export([start/2, stop/1]).

%% -include_lib("/lib/nksip/include/nkserver_module.hrl").

start(_StartType, _StartArgs) ->
    try_nksip_sup:start_link().

stop(_State) ->
    ok.

%% internal functions