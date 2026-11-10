-module(riego_controller).
-behaviour(gen_server).
-export([start_link/0,state/0,command/1,init/1,handle_call/3,handle_cast/2,handle_info/2]).
start_link() -> gen_server:start_link({local,?MODULE},?MODULE,[],[]).
state() -> gen_server:call(?MODULE,state).
command(C) -> gen_server:call(?MODULE,C).
path() -> filename:join(application:get_env(riego,data_dir,"data"),"state.term").
init([]) ->
 ok=filelib:ensure_dir(path()),
 S=case file:read_file(path()) of
 {ok,B} -> riego_model:recover(binary_to_term(B,[safe]));
 {error,enoent} -> riego_model:new();
 {error,E} -> error({persistence,E}) end,
 close(), erlang:send_after(1000,self(),tick), {ok,save(S)}.
close() -> [riego_valve:set(I,closed)||I<-lists:seq(1,12)],ok.
save(S) ->
 P=path(),ok=file:write_file(P++".tmp",term_to_binary(S),[sync]),
 ok=file:rename(P++".tmp",P),S.
apply_state(S) ->
 %% Close first, persist desired state, then open. No transient capacity excess.
 close(), save(S),
 [begin riego_valve:set(maps:get(zone,J),opening),riego_valve:set(maps:get(zone,J),open) end || J<-maps:get(active,S)], S.
handle_call(state,_,S) -> {reply,S,S};
handle_call({program,Z,D,P},_,S) ->
 case riego_model:submit(Z,D,P,erlang:system_time(second),S) of
 {ok,N} -> {reply,ok,save(N)}; E -> {reply,E,S} end;
handle_call({signal,K,V},_,S) ->
 try riego_model:signal(K,V,S) of N ->
 N1=riego_model:step(erlang:system_time(second),erlang:monotonic_time(second),N),
 {reply,ok,apply_state(N1)}
 catch error:bad_signal -> {reply,{error,invalid_signal},S} end;
handle_call(_,_,S) -> {reply,{error,invalid_command},S}.
handle_cast(_,S) -> {noreply,S}.
handle_info(tick,S) ->
 N=riego_model:step(erlang:system_time(second),erlang:monotonic_time(second),S),
 N1=apply_state(N),erlang:send_after(1000,self(),tick),{noreply,N1};
handle_info(_,S) -> {noreply,S}.
