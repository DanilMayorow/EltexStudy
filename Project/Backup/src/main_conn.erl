-module(main_conn).

-export([test/0, invite/3]).

-define(IP, "192.168.2.36").
-define(DOMAIN, "ltx").

test() ->
    Client1 = string:concat("sip:1000@", ?IP),
    nksip:start_link(client1, 
        #{sip_from => Client1,
          plugins => [nksip_uac_auto_auth],
          sip_listen => "<sip:all:10000>, <sip:all:10001;transport=udp>"
        }),
    
    PBX_ID = string:concat("sip:", ?DOMAIN),
    nksip_uac:register(client1, PBX_ID,
        [{sip_pass, "12345"}, contact, {meta, ["contact"]}]),
    io:format("Register~n"),
    timer:sleep(120000),
    io:format("Register test end~n"),
    %Client2 = string:concat("sip:1001@", ?IP),
    %InviteOptions = [{add, "x-nk-op", ok}, {add, "x-nk-prov", true},
    %  {add, "x-nk-sleep", 8000},
    %  auto_2xx_ack,
    %  {sip_pass, "12345"}
    %],
  %invite(5, Client2, InviteOptions),
  nksip:stop(client1).

invite(0, _, _) ->
  erlang:error(noinvite);
invite(Acc, Client2, InviteOps) when Acc > 0 ->
  case  nksip_uac:invite(client1, Client2, InviteOps) of
    {ok, 200, [{dialog, DlgId}]} ->
      io:format("Success ~p try~n",[Acc]),
      timer:sleep(10000),
      nksip_uac:bye(DlgId, []),
      {ok, self()};
    _Error ->
      io:format("Fail on ~p try, wait and repeat~n",[Acc]),
      timer:sleep(4000),
      invite(Acc - 1, Client2, InviteOps)
  end.