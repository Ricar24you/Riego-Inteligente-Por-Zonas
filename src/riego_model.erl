%% Pure safety policy. All durations are seconds; priority 0 is highest.
-module(riego_model).
-export([new/0,submit/5,step/3,signal/3,recover/1,window/1]).
new() -> #{queue=>[],active=>[],rain=>false,fault=>false,completed=>0,deferred=>0,
 liters=>0.0,events=>[],sequence=>0,last_wall=>0,last_mono=>0}.
window(W) -> H=(W rem 86400 + 86400) rem 86400, H>=79200 orelse H<21600.
remaining(W) -> H=(W rem 86400 + 86400) rem 86400,
 case H>=79200 of true -> 108000-H; false -> 21600-H end.
submit(Z,D,P,W,S) when is_integer(Z),Z>=1,Z=<12,is_integer(D),D>0,D=<28800,
 is_integer(P),P>=0,P=<9 ->
 Jobs=maps:get(queue,S)++maps:get(active,S),
 case length(Jobs)>=120 orelse lists:any(fun(J)->maps:get(zone,J)=:=Z end,Jobs) of
 true -> {error,busy};
 false -> N=maps:get(sequence,S)+1,
 J=#{zone=>Z,remaining=>D,priority=>P,id=>N,created=>W},
 {ok,event(queued,S#{queue=>maps:get(queue,S)++[J],sequence=>N})} end;
submit(_,_,_,_,_) -> {error,invalid_program}.
recover(S) -> event(recovered,S#{queue=>maps:get(active,S)++maps:get(queue,S),active=>[],last_wall=>0,last_mono=>0}).
signal(rain,B,S) when is_boolean(B) -> event(rain,S#{rain=>B});
signal(stuck,Z,S) when is_integer(Z),Z>=1,Z=<12 -> event(stuck,S#{fault=>true});
signal(flow,F,S) when is_number(F),F>=0 ->
 case maps:get(active,S)=:=[] andalso F>0 of true -> event(leak,S#{fault=>true}); false -> S end;
signal(reset,true,S) -> event(reset,S#{fault=>false});
signal(_,_,_) -> error(bad_signal).
step(W,M,S) ->
 LW=maps:get(last_wall,S), LM=maps:get(last_mono,S),
 Drift=LW=/=0 andalso abs((W-LW)-(M-LM))>5,
 S0=case Drift of true -> event(clock_jump,S#{fault=>true}); false -> S end,
 Dt=case LW of 0 -> 0; _ -> max(0,M-LM) end,
 S1=S0#{last_wall=>W,last_mono=>M},
 case maps:get(rain,S1) orelse maps:get(fault,S1) orelse not window(W) of
 true -> A=maps:get(active,S1),
 S1#{active=>[],queue=>A++maps:get(queue,S1)};
 false ->
 A0=maps:get(active,S1),
 Done=[J || J<-A0,maps:get(remaining,J)=<Dt],
 A=[J#{remaining=>maps:get(remaining,J)-Dt} || J<-A0,maps:get(remaining,J)>Dt],
 Lit=lists:sum([min(Dt,maps:get(remaining,J))*0.1 || J<-A0]),
 Sorted=lists:sort(fun(X,Y)->{maps:get(priority,X),maps:get(id,X)} < {maps:get(priority,Y),maps:get(id,Y)} end,maps:get(queue,S1)),
 {A1,Q}=dispatch(Sorted,A,[],remaining(W)),
 S1#{active=>A1,queue=>Q,completed=>maps:get(completed,S1)+length(Done),
 liters=>maps:get(liters,S1)+Lit,deferred=>length([J || J<-Q,maps:get(remaining,J)>remaining(W)])}
 end.
dispatch([],A,Q,_) -> {A,lists:reverse(Q)};
dispatch([J|Js],A,Q,R) ->
 case length(A)<3 andalso maps:get(remaining,J)=<R of
 true -> dispatch(Js,A++[J],Q,R);
 false -> dispatch(Js,A,[J|Q],R) end.
event(E,S) -> S#{events=>lists:sublist([#{event=>E,at=>erlang:system_time(second)}|maps:get(events,S)],100)}.
