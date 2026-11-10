-module(riego_model_tests).
-include_lib("eunit/include/eunit.hrl").
night() -> 79200.
filled() -> lists:foldl(fun(Z,S)->{ok,N}=riego_model:submit(Z,60,(12-Z) rem 10,night(),S),N end,riego_model:new(),lists:seq(1,12)).
capacity_priority_test() -> S=riego_model:step(night(),1,filled()),
 ?assertEqual([2,12,1],[maps:get(zone,J)||J<-maps:get(active,S)]),?assertEqual(9,length(maps:get(queue,S))).
rain_test() -> S=riego_model:step(night(),1,filled()),N=riego_model:step(night()+1,2,riego_model:signal(rain,true,S)),?assertEqual([],maps:get(active,N)),?assertEqual(12,length(maps:get(queue,N))).
completion_test() -> S=riego_model:step(night(),1,filled()),N=riego_model:step(night()+60,61,S),?assertEqual(3,maps:get(completed,N)),?assertEqual(18.0,maps:get(liters,N)).
window_test() -> ?assertNot(riego_model:window(21600)),?assert(riego_model:window(0)),?assertEqual([],maps:get(active,riego_model:step(43200,1,filled()))).
overflow_test() -> {ok,S}=riego_model:submit(1,60,0,21590,riego_model:new()),N=riego_model:step(21590,1,S),?assertEqual([],maps:get(active,N)),?assertEqual(1,maps:get(deferred,N)).
fault_test() -> S=riego_model:signal(stuck,1,filled()),?assertEqual([],maps:get(active,riego_model:step(night(),1,S))),?assert(maps:get(fault,riego_model:signal(flow,1,riego_model:new()))).
clock_test() -> S=riego_model:step(night(),1,filled()),N=riego_model:step(night()+100,2,S),?assert(maps:get(fault,N)),?assertEqual([],maps:get(active,N)).
recovery_test() -> S=riego_model:step(night(),1,filled()),N=riego_model:recover(S),?assertEqual([],maps:get(active,N)),?assertEqual(12,length(maps:get(queue,N))).
validation_test() -> ?assertEqual({error,invalid_program},riego_model:submit(13,60,1,0,riego_model:new())),{ok,S}=riego_model:submit(1,1,1,0,riego_model:new()),?assertEqual({error,busy},riego_model:submit(1,1,1,0,S)).
capacity_over_time_test() -> lists:foldl(fun(T,S)->N=riego_model:step(night()+T,T,S),?assert(length(maps:get(active,N))=<3),N end,filled(),lists:seq(1,300)).
