%%%-------------------------------------------------------------------
%% @doc try_nksip public API
%% @end
%%%-------------------------------------------------------------------

-module(try_nksip_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    try_nksip_sup:start_link().

stop(_State) ->
    ok.