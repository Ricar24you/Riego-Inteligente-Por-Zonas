-module(riego_app).
-behaviour(application).
-export([start/2,stop/1]).
start(_,_) -> riego_sup:start_link().
stop(_) -> ok.
