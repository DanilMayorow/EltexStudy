%%%-------------------------------------------------------------------
%% @doc try_nksip top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(try_nksip_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  SupFlags = #{strategy => one_for_all,
    intensity => 0,
    period => 1},
  ChildSpecs = [#{id => nk_user,
    start => {main_conn, test, []},
    restart => temporary,
    shutdown => brutal_kill
  }],
  {ok, {SupFlags, ChildSpecs}}.
