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
