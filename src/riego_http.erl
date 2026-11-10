-module(riego_http).
-behaviour(gen_server).
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,terminate/2]).
-export([start_link/0,init/2,websocket_init/1,websocket_handle/2,websocket_info/2]).
start_link() -> gen_server:start_link(?MODULE,[],[]).
init([]) ->
 process_flag(trap_exit,true),
 Routes=cowboy_router:compile([{'_', [{"/ws",?MODULE,ws},{"/api/[...]",?MODULE,api},{"/metrics",?MODULE,metrics},{"/",cowboy_static,{priv_file,riego,"www/index.html"}}]}]),
 {ok,_}=cowboy:start_clear(riego_listener,[{ip,{127,0,0,1}},{port,application:get_env(riego,port,8080)}],#{env=>#{dispatch=>Routes}}), {ok,#{}}.
handle_call(_,_,S) -> {reply,ok,S}.
handle_cast(_,S) -> {noreply,S}.
handle_info(_,S) -> {noreply,S}.
terminate(_,_) -> cowboy:stop_listener(riego_listener).
init(R,ws) -> {cowboy_websocket,R,#{},#{idle_timeout=>60000}};
init(R,metrics) ->
 S=riego_controller:state(), B=io_lib:format("riego_active ~p~nriego_completed ~p~nriego_liters ~p~nriego_fault ~p~n",[length(maps:get(active,S)),maps:get(completed,S),maps:get(liters,S),case maps:get(fault,S) of true->1;false->0 end]),
 {ok,cowboy_req:reply(200,#{<<"content-type">>=><<"text/plain">>},B,R),metrics};
init(R,api) ->
 try route(cowboy_req:method(R),cowboy_req:path(R),R) of
 {Code,B,R1} -> {ok,cowboy_req:reply(Code,#{<<"content-type">>=><<"application/json">>},jsx:encode(B),R1),api}
 catch _:_ -> {ok,cowboy_req:reply(400,#{<<"content-type">>=><<"application/json">>},<<"{\"error\":\"invalid_request\"}">>,R),api} end.
route(<<"GET">>,P,R) when P=:=<<"/api/state">>; P=:=<<"/api/programas">>; P=:=<<"/api/valvulas">> -> {200,riego_controller:state(),R};
route(<<"POST">>,P,R) ->
 <<"application/json",_/binary>>=cowboy_req:header(<<"content-type">>,R,<<>>),
 Origin=cowboy_req:header(<<"origin">>,R),
 true=(Origin=:=undefined orelse Origin=:= <<"http://",(cowboy_req:host(R))/binary,":",(integer_to_binary(cowboy_req:port(R)))/binary>>),
 {ok,B,R1}=cowboy_req:read_body(R,#{length=>4096,period=>1000}),J=jsx:decode(B,[return_maps]),
 C=case P of
 <<"/api/programas">> -> {program,maps:get(<<"zone">>,J),maps:get(<<"duration">>,J),maps:get(<<"priority">>,J)};
 <<"/api/signal">> -> {signal,signal_key(maps:get(<<"kind">>,J)),maps:get(<<"value">>,J)} end,
 case riego_controller:command(C) of ok -> {200,#{ok=>true},R1}; {error,E} -> {422,#{error=>E},R1} end;
route(_,_,R) -> {404,#{error=>not_found},R}.
signal_key(<<"rain">>)->rain; signal_key(<<"stuck">>)->stuck; signal_key(<<"flow">>)->flow; signal_key(<<"reset">>)->reset.
websocket_init(S) -> self()!update,{ok,S}.
websocket_handle(_,S) -> {ok,S}.
websocket_info(update,S) -> erlang:send_after(1000,self(),update),{reply,{text,jsx:encode(riego_controller:state())},S}.
