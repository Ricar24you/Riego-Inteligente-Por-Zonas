-module(riego_sup).
-behaviour(supervisor).
-export([start_link/0,init/1]).
start_link() -> supervisor:start_link({local,?MODULE},?MODULE,[]).
init([]) ->
 V=[#{id=>{zone,I},start=>{riego_valve,start_link,[I]}} || I<-lists:seq(1,12)],
 C=[#{id=>riego_controller,start=>{riego_controller,start_link,[]}},
    #{id=>riego_http,start=>{riego_http,start_link,[]}}],
 {ok,{#{strategy=>rest_for_one,intensity=>30,period=>60},V++C}}.
