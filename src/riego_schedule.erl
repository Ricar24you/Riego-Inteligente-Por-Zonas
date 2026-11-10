%% Local civil start time, fixed elapsed duration (including across DST changes).
%% TZ must be selected before starting the VM; no process-global TZ mutation.
-module(riego_schedule).
-export([default/0, configured/0, remaining/2, label/1]).

default() -> #{timezone => utc, start_hour => 22, duration_hours => 8}.

configured() ->
    C = application:get_env(riego, schedule,
        #{timezone => local, start_hour => 22, duration_hours => 8}),
    #{timezone := Zone, start_hour := H, duration_hours := D} = C,
    true = (Zone =:= local orelse Zone =:= utc),
    true = (is_integer(H) andalso H >= 0 andalso H < 24),
    true = (is_integer(D) andalso D >= 1 andalso D =< 8),
    case {Zone, os:getenv("TZ")} of
        {local, TZ} when is_list(TZ) ->
            %% Reject libc's silent fallback to UTC on a misspelled IANA name.
            true = (filename:pathtype(TZ) =:= relative),
            false = lists:member("..", filename:split(TZ)),
            true = filelib:is_regular(filename:join("/usr/share/zoneinfo", TZ));
        _ -> ok
    end,
    C.

label(#{timezone := utc}) -> <<"UTC">>;
label(#{timezone := local}) ->
    case os:getenv("TZ") of
        false -> <<"Sistema local (/etc/localtime)">>;
        TZ -> list_to_binary(TZ)
    end.

remaining(W, #{timezone := Zone, start_hour := H, duration_hours := D}) ->
    {Date, _} = civil(W, Zone),
    Day = calendar:date_to_gregorian_days(Date),
    Starts = lists:append([starts(calendar:gregorian_days_to_date(N), H, Zone)
        || N <- [Day - 1, Day]]),
    %% An ambiguous local start occurs once (earliest UTC instant). A nonexistent
    %% local start is skipped on that date rather than moved silently.
    Ends = [S + D * 3600 || S <- Starts, W >= S, W < S + D * 3600],
    case Ends of [] -> 0; _ -> lists:max(Ends) - W end.

civil(W, utc) -> calendar:system_time_to_universal_time(W, second);
civil(W, local) -> calendar:system_time_to_local_time(W, second).

starts(Date, H, Zone) ->
    Local = {Date, {H, 0, 0}},
    UTCs = case Zone of
        utc -> [Local];
        local -> calendar:local_time_to_universal_time_dst(Local)
    end,
    Epoch = calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}}),
    case UTCs of
        [] -> [];
        _ -> [lists:min([calendar:datetime_to_gregorian_seconds(U) - Epoch || U <- UTCs])]
    end.
