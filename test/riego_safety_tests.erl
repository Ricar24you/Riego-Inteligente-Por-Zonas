-module(riego_safety_tests).
-include_lib("eunit/include/eunit.hrl").

stuck_remains_open_test() ->
    {ok,P}=riego_valve:start_link(12),
    try
        ok=riego_valve:set(12,open),
        ok=riego_valve:set(12,stuck_open),
        ?assertEqual({error,stuck_open},riego_valve:set(12,closed)),
        ?assertEqual(stuck_open,riego_valve:state(12)),
        ok=riego_valve:set(12,repair),
        ?assertEqual(closed,riego_valve:state(12))
    after unlink(P),exit(P,shutdown) end.

stuck_interlock_test() ->
    {ok,S}=riego_model:submit(1,60,0,79200,riego_model:new()),
    Running=riego_model:step(79200,1,S),
    ?assert(maps:get(pump,Running)),
    Fault=riego_model:step(79201,2,riego_model:signal(stuck,1,Running)),
    ?assertEqual([1],maps:get(stuck,Fault)),
    ?assertNot(maps:get(pump,Fault)),
    ?assertEqual([],maps:get(active,Fault)),
    ?assertEqual(1,length(maps:get(queue,Fault))),
    ?assertError(repair_required,riego_model:signal(reset,true,Fault)),
    Recovered=riego_model:recover(Fault),
    ?assertEqual([1],maps:get(stuck,Recovered)),
    ?assertNot(maps:get(pump,Recovered)),
    Repaired=riego_model:signal(repair,1,Recovered),
    ?assert(maps:get(fault,Repaired)),
    Safe=riego_model:step(79202,3,Repaired),
    ?assertNot(maps:get(pump,Safe)),
    Resumed=riego_model:step(79203,4,riego_model:signal(reset,true,Safe)),
    ?assert(maps:get(pump,Resumed)),
    ?assertEqual(1,length(maps:get(active,Resumed))).

multiple_stuck_test() ->
    S=riego_model:signal(stuck,2,riego_model:signal(stuck,1,riego_model:new())),
    N=riego_model:signal(repair,1,S),
    ?assertError(repair_required,riego_model:signal(reset,true,N)),
    ?assertEqual([2],maps:get(stuck,N)).

legacy_state_migration_test() ->
    Legacy=maps:without([stuck,pump,schedule],riego_model:new()),
    S=riego_model:recover(Legacy),
    ?assertEqual([],maps:get(stuck,S)),
    ?assertNot(maps:get(pump,S)),
    ?assertEqual(riego_schedule:default(),maps:get(schedule,S)).

configurable_start_test() ->
    C=#{timezone=>utc,start_hour=>20,duration_hours=>6},
    ?assertEqual(21600,riego_schedule:remaining(72000,C)),
    ?assertEqual(0,riego_schedule:remaining(7200,C)).
