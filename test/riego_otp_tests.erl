-module(riego_otp_tests).
-include_lib("eunit/include/eunit.hrl").
recovery_test_() -> {timeout,20,fun() ->
 Dir=filename:join("/tmp","riego-test-"++integer_to_list(erlang:unique_integer([positive]))),
 application:load(riego),application:set_env(riego,data_dir,Dir),application:set_env(riego,port,0),
 {ok,_}=application:ensure_all_started(riego),
 try
 ok=riego_controller:command({program,1,60,0}),
 P=whereis(riego_controller),exit(P,kill),wait_new(P,100),
 S=riego_controller:state(),?assertEqual(1,length(maps:get(queue,S))),
 ?assertEqual([],maps:get(active,S)),?assertEqual(closed,riego_valve:state(1)),
 exit(whereis(riego_zone_1),kill),timer:sleep(100),
 ?assert(is_pid(whereis(riego_controller))),?assertEqual(closed,riego_valve:state(1)),
 ok=riego_controller:command({signal,flow,2}),?assert(maps:get(fault,riego_controller:state()))
 after application:stop(riego), file:del_dir_r(Dir) end end}.
wait_new(_,0)->error(restart_timeout);
wait_new(P,N)->case whereis(riego_controller) of Q when is_pid(Q),Q=/=P->ok;_->timer:sleep(20),wait_new(P,N-1) end.

stuck_survives_restart_test_() -> {timeout,20,fun() ->
 Dir=filename:join("/tmp","riego-stuck-"++integer_to_list(erlang:unique_integer([positive]))),
 application:load(riego),
 OldSchedule=application:get_env(riego,schedule),
 {{_,_,_},{Hour,_,_}}=calendar:universal_time(),
 application:set_env(riego,schedule,#{timezone=>utc,start_hour=>Hour,duration_hours=>8}),
 application:set_env(riego,data_dir,Dir),application:set_env(riego,port,0),
 {ok,_}=application:ensure_all_started(riego),
 try
     ok=riego_controller:command({program,1,120,0}),
     whereis(riego_controller)!tick,
     Running=riego_controller:state(),
     ?assert(maps:get(pump,Running)),
     ?assertEqual(open,riego_valve:state(1)),
     ok=riego_controller:command({signal,stuck,1}),
     ?assertEqual(stuck_open,riego_valve:state(1)),
     ?assertEqual({error,stuck_open},riego_valve:set(1,closed)),
     ?assertEqual({error,repair_required},riego_controller:command({signal,reset,true})),
     Fault=riego_controller:state(),
     ?assertNot(maps:get(pump,Fault)),
     ?assertEqual(0.0,maps:get(flow_lps,Fault)),
     ?assertEqual([],maps:get(active,Fault)),
     P=whereis(riego_controller),exit(P,kill),wait_new(P,100),
     ?assertEqual([1],maps:get(stuck,riego_controller:state())),
     ?assertEqual(stuck_open,riego_valve:state(1)),
     %% A crashed actuator process must not magically repair a mechanical jam.
     P2=whereis(riego_controller),exit(whereis(riego_zone_1),kill),wait_new(P2,100),
     ?assertEqual(stuck_open,riego_valve:state(1)),
     ok=application:stop(riego),
     {ok,_}=application:ensure_all_started(riego),
     ?assertEqual(stuck_open,riego_valve:state(1)),
     ?assertNot(maps:get(pump,riego_controller:state())),
     ok=riego_controller:command({signal,repair,1}),
     ?assertEqual(closed,riego_valve:state(1)),
     ?assert(maps:get(fault,riego_controller:state())),
     ok=riego_controller:command({signal,reset,true}),
     Resumed=riego_controller:state(),
     ?assert(maps:get(pump,Resumed)),
     ?assertEqual(1,length(maps:get(active,Resumed)))
 after
     application:stop(riego), file:del_dir_r(Dir),
     case OldSchedule of {ok,C}->application:set_env(riego,schedule,C);
         undefined->application:unset_env(riego,schedule) end
 end end}.
