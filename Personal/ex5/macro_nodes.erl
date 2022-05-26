%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 25. май 2022 11:25
%%%-------------------------------------------------------------------
-module(macro_nodes).
-author("Dann Maj").

%Макрос возведения в степень
-define(pow,
  (fun Pow(_Base, 0) -> 1;
    Pow(Base, Power) when Power < 0 -> (1/Base)*Pow(Base, Power+1);
    Pow(Base, Power) -> Base*Pow(Base, Power-1)
       end)).

%% API
-export([main/0, listener/0, sender/1]).

main() ->
  io:format("Try our macro:~p~n",[?pow(4,10)]),
  io:format("Create listener node...~nPlease open another termanal and call sender()~n"),
  listener(),
  io:format("All right!~n").

listener() ->
  net_kernel:start([lsnr,shortnames]),
  register(lsnr, self()),
  receive
    {SNDR,Msg} -> ok = io:format("They say: ~s~n",[Msg]),
      SNDR ! {self(), "I'm get your message, thanks!"}
  end, ok.

sender(Text) ->
  net_kernel:start([sndr,shortnames]),
  net_kernel:connect_node('lsnr@dannmaj-ubnt'),
  register(sndr, self()),
  {lsnr, 'lsnr@dannmaj-ubnt'} ! {self(), Text},
  receive
    {_LSNR, Msg} -> ok=io:format("~s~n",[Msg])
  end,
  unregister(sndr),
  net_kernel:stop().
