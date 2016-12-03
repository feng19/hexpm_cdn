-module(hexpm_cdn).

-define(DEFAULT_CDN, "https://repo.hex.pm").

-export([
    start/0,
    init/3,
    handle/2,
    terminate/3
]).

start() ->
    application:ensure_all_started(?MODULE).

init(_Type, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {ExtraPath, _} = cowboy_req:path(Req),
    {Qs, _} = cowboy_req:qs(Req),
    Url = url_append_path(ExtraPath, Qs),

    {Code, Headers, Body} = request(binary_to_list(Url)),
%%    io:format("~p~n", [{Code, Headers, Body}]),
    {ok, Req2} = cowboy_req:reply(Code, Headers, Body, Req),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

request(Url) ->
    {ok, {{_Version, Code, _Reason}, Headers, Body}} = httpc:request(get, {Url, []}, [{relaxed, true}], [{body_format, binary}]),
    {Code, Headers, Body}.

url_append_path(ExtraPath, <<>>) ->
    <<?DEFAULT_CDN, ExtraPath/binary>>;
url_append_path(ExtraPath, Qs) ->
    <<?DEFAULT_CDN, ExtraPath/binary, "?", Qs/binary>>.