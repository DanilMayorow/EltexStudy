%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(first_step).
-author("Dann Maj").

%% API
-export([main/0, try_io/0, try_math/0]).

main() -> try_io(), try_math().

try_io()->
  io:format("Standart output on display~n"),
  {ok, In} = io:fread("Now, input smth on keyboard:","~s"),
  io:fwrite("And this is what you entered '~s', yeah? ~n", In),
  io:fwrite("Next to we are read file 'read_test.txt'~n"),
  {Result, OUT} = file:open("test_read.txt", [read]),
  if Result == ok -> io:format("File exported!~n"),
    try
      File = get_all_lines(OUT),
      Data = string:split(File,"\n", all),
      io:fwrite("Data readed:~p~n",[Data])
    after file:close(OUT)
    end;
    true -> io:format("File doesn't exported!~nResult:~p Info:~p~n",[Result, OUT])
  end.

get_all_lines(Device) ->
  case io:get_line(Device, "promt") of
    eof  -> [];
    Line -> Line ++ get_all_lines(Device)
  end.

try_math() ->
  io:format("Now, we'll try math module:~n"),
  Pi = math:pi(),
  X = 1,
  X2 = X / 2,
  io:format("We arleady add constants: Pi=~f X=~w X2=~f~n", [Pi, X, X2]),
  Big = math:pow(math:pow(2,10),20),
  io:format("Now, we try exponentiate a large number ~e~n",[Big]),
  io:format("And calc sin(Pi/2)=~f, cos(60)=~f, tan(Pi/4)=~f, ln=~e and log2=~p~n",[math:sin(Pi*X2),math:cos(Pi/3),math:tan(Pi/4),math:log(Big),math:log2(Big)]).