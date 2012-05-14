%%% Main supervisor for Erlami application.
%%%
%%% Copyright 2012 Marcelo Gornstein <marcelog@gmail.com>
%%%
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%%     http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
-module(erlami_sup).
-author("Marcelo Gornstein <marcelog@gmail.com>").
-github("https://github.com/marcelog").
-homepage("http://marcelog.github.com/").
-license("Apache License 2.0").
-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(
    CHILD(Name, Args),
    {Name,
        {erlami_client, start_link, Args},
        permanent, 5000, worker, [?MODULE]
    }
).

%% ===================================================================
%% API functions
%% ===================================================================
start_link(AsteriskServers) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, AsteriskServers).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================
init(AsteriskServers) ->
    Children = lists:map(
        fun({ServerName, ServerInfo}) ->
            WorkerName = erlami_client:get_worker_name(ServerName),
            ?CHILD(ServerName, [ServerName, WorkerName, ServerInfo])
        end,
        AsteriskServers
    ),
    {ok, { {one_for_one, 5, 10}, Children} }.
