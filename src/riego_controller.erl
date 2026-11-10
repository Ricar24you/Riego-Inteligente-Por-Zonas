-module(riego_controller).
-behaviour(gen_server).
-export([start_link/0,state/0,command/1,init/1,handle_call/3,handle_cast/2,handle_info/2]).
start_link() -> gen_server:start_link({local,?MODULE},?MODULE,[],[]).
state() -> gen_server:call(?MODULE,state).
command(C) -> gen_server:call(?MODULE,C).
path() -> filename:join(application:get_env(riego,data_dir,"data"),"state.term").
init([]) ->
 %% Safe term decoding must recognize persisted atoms in a fresh VM, too.
 {module,riego_model}=code:ensure_loaded(riego_model),
 {module,riego_schedule}=code:ensure_loaded(riego_schedule),
 ok=filelib:ensure_dir(path()),
 S=case file:read_file(path()) of
 {ok,B} -> riego_model:recover(binary_to_term(B,[safe]));
 {error,enoent} -> riego_model:new();
 {error,E} -> error({persistence,E}) end,
 N=S#{schedule=>riego_schedule:configured()},
 erlang:send_after(1000,self(),tick), {ok,apply_state(N)}.
close(S) ->
 [case lists:member(I,maps:get(stuck,S)) of
 true -> riego_valve:set(I,stuck_open);
 false -> case riego_valve:state(I) of
 stuck_open -> riego_valve:set(I,repair);
 _ -> riego_valve:set(I,closed)
 end end || I<-lists:seq(1,12)],ok.
save(S) ->
 P=path(),ok=file:write_file(P++".tmp",term_to_binary(S),[sync]),
 ok=file:rename(P++".tmp",P),S.
apply_state(S) ->
 %% Persist the jam/interlock before acknowledging it, close commanded outputs,
 %% then open scheduled zones. A jam cannot be closed by an ordinary command.
 save(S), close(S),
 [begin riego_valve:set(maps:get(zone,J),opening),riego_valve:set(maps:get(zone,J),open) end || J<-maps:get(active,S)], S.
handle_call(state,_,S) ->
 A=[maps:get(zone,J)||J<-maps:get(active,S)],
 Valves=[#{zone=>I,commanded=>case lists:member(I,A) of true->open;false->closed end,
 physical=>riego_valve:state(I)} || I<-lists:seq(1,12)],
 Schedule=maps:get(schedule,S),
 View=S#{valves=>Valves,flow_lps=>case maps:get(pump,S) of true->length(A)*0.1;false->0.0 end,
 schedule=>Schedule#{timezone_name=>riego_schedule:label(Schedule),
 remaining_seconds=>riego_schedule:remaining(erlang:system_time(second),Schedule)}},
 {reply,View,S};
handle_call({program,Z,D,P},_,S) ->
 case riego_model:submit(Z,D,P,erlang:system_time(second),S) of
 {ok,N} -> {reply,ok,save(N)}; E -> {reply,E,S} end;
handle_call({signal,K,V},_,S) ->
 try riego_model:signal(K,V,S) of N ->
 N1=riego_model:step(erlang:system_time(second),erlang:monotonic_time(second),N),
 {reply,ok,apply_state(N1)}
 catch error:bad_signal -> {reply,{error,invalid_signal},S};
 error:repair_required -> {reply,{error,repair_required},S} end;
handle_call(_,_,S) -> {reply,{error,invalid_command},S}.
handle_cast(_,S) -> {noreply,S}.
handle_info(tick,S) ->
 N=riego_model:step(erlang:system_time(second),erlang:monotonic_time(second),S),
 N1=apply_state(N),erlang:send_after(1000,self(),tick),{noreply,N1};
handle_info(_,S) -> {noreply,S}.
