%%%-------------------------------------------------------------------
%% @doc web public API
%% @end
%%%-------------------------------------------------------------------

-module(web_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    web_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
