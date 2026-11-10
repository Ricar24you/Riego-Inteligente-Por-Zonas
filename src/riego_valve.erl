-module(riego_valve).
-behaviour(gen_statem).
-export([start_link/1,set/2,state/1,callback_mode/0,init/1,handle_event/4]).
name(I) -> list_to_atom("riego_zone_"++integer_to_list(I)).
start_link(I) -> gen_statem:start_link({local,name(I)},?MODULE,[],[]).
set(I,S) -> gen_statem:call(name(I),{set,S}).
state(I) -> gen_statem:call(name(I),state).
callback_mode() -> handle_event_function.
init([]) -> {ok,closed,#{}}.
handle_event({call,F},state,S,D) -> {keep_state,D,[{reply,F,S}]};
handle_event({call,F},{set,S},_,D) when S=:=closed; S=:=opening; S=:=open; S=:=fault ->
 {next_state,S,D,[{reply,F,ok}]};
handle_event(_,_,_,D) -> {keep_state,D}.
