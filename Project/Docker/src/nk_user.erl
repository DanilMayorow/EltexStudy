-module(nk_user).

-export([test/0]).

-define(DOMAIN, "192.168.2.36").

test() ->
    Client1 = string:concat("sip:1001@", ?DOMAIN),
    nksip:start_link(client1, 
        #{sip_from => Client1,
          plugins => [nksip_uac_auto_auth],
          sip_listen => "<sip:all:10000>, <sip:all:10001;transport=udp>"
        }),
    
    PBX_ID = string:concat("sip:", ?DOMAIN),
    nksip_uac:register(client1, PBX_ID,
        [{sip_pass, "12345"}, contact, {meta, ["contact"]}]),
    
    Client2 = string:concat("sip:1001@", ?DOMAIN),
    nksip_uac:invite(client1, Client2,
        [{add, "x-nk-op", ok}, {add, "x-nk-prov", true},
         {add, "x-nk-sleep", 8000},
         auto_2xx_ack,
         {sip_pass, "12345"} %, {route, "<sip:192.168.2.2;lr>"}
        ]),
    
    % nksip_uac:bye(DlgId, []),

    {ok, self()}.   %% for correct exit without error(bad_return)