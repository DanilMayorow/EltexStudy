-module(main_conn).

-export([test/0, invite/3]).

-include_lib("../nksip/include/nksip.hrl").

-define(IP, "192.168.2.36").
-define(DOMAIN, "ltx").

test() ->

  Client1 = string:concat("sip:1000@", ?DOMAIN),
  nksip:start_link(client1,
    #{sip_from => Client1,
      plugins => [nksip_uac_auto_auth],
      sip_listen => "<sip:all:10000>, <sip:all:10001;transport=udp>"
    }),

  PBX_ID = string:concat("sip:", ?IP),
  nksip_uac:register(client1, PBX_ID,
    [{sip_pass, "12345"}, contact, {meta, ["contact"]}]),
  io:format("Register~n"),

  Client2 = string:concat("sip:1001@", ?IP),

  SDP = #sdp{address = {<<"IN">>, <<"IP4">>, erlang:list_to_binary(?IP)},
    connect = {<<"IN">>, <<"IP4">>, erlang:list_to_binary(?IP)},
    time = [{0, 0, []}],
    medias = [#sdp_m{media = <<"audio">>,
      port = 9990,
      proto = <<"RTP/AVP">>,
      fmt = [<<"0">>, <<"8">>, <<"101">>, <<"127">>],
      attributes = [{<<"sendrecv">>, []}]
    }
    ]
  },

  InviteOptions = [{add, "x-nk-op", ok},
    {add, "x-nk-prov", true},
    {add, "x-nk-sleep", 8000},
    auto_2xx_ack,
    {sip_dialog_timeout, 45000},
    {sip_pass, "12345"},
    {body, SDP}
  ],

  invite(5, Client2, InviteOptions),
  nksip:stop(client1).

invite(0, _, _) ->
  erlang:error(noinvite);
invite(Acc, Client2, InviteOps) when Acc > 0 ->
  case nksip_uac:invite(client1, Client2, InviteOps) of
    {ok, 200, [{dialog, DlgId}]} ->
      io:format("Success ~p try~n", [Acc]),
      {ok, SDPRemoteVoice} = nksip_dialog:get_meta(invite_remote_sdp, DlgId),
      erlang:display(nksip_dialog:get_metas([invite_status,invite_answered,invite_local_sdp,invite_remote_sdp,invite_timeout],DlgId)),
      [SDP_M | _] = SDPRemoteVoice#sdp.medias,
      Port = SDP_M#sdp_m.port,
      erlang:display(Port),
      Message = "Проверка курсовой работы Майорова Данила",
      GenVoice = "wget -O priv/voice/generate.wav \"https://tts.voicetech.yandex.net/generate?format=wav&lang=ru_RU&key=069b6659-984b-4c5f-880e-aaedcfd84102&text="
        ++ string:join(string:tokens(Message," "),"%20") ++ "\"",
      ConvertVoice = "ffmpeg -i priv/voice/generate.wav -codec:a pcm_mulaw -ar 8000 -ac 1 priv/voice/output.wav -y",
      StartVoice = "./voice_client priv/voice/output.wav " ++ "192.168.2.36" ++ " " ++ erlang:integer_to_list(Port), %erlang:binary_to_list(IPR)
      Cmd = "echo Generate &&" ++ GenVoice
        ++ " && echo Convert" ++ " && " ++ ConvertVoice
        ++ " && echo Start" ++ " && " ++ StartVoice,
      timer:sleep(3000),
      Res = os:cmd(Cmd),
      io:format("Res: ~n~s",[Res]),
      timer:sleep(15000),
      nksip_uac:bye(DlgId, []),
      {stop, normal};
    _Error ->
      io:format("Fail on ~p try, wait and repeat~n", [Acc]),
      timer:sleep(4000),
      invite(Acc - 1, Client2, InviteOps)
  end.