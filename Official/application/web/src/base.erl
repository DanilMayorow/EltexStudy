%%%-------------------------------------------------------------------
%%% @author dannmaj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июнь 2022 15:15
%%%-------------------------------------------------------------------
-module(base).
-author("dannmaj").

%% API
-export([connect/0]).

connect() ->
  {ok, PID} = mysql:start_link([{host, "localhost"}, {user, "erl"}, {password, "Freedom95+"},{database, "erlang"}]),
  Data= mysql:query(PID, <<"SELECT * FROM users">>),
  Data.