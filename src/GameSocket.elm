module GameSocket exposing (..)

import Phoenix.Socket
import Phoenix.Channel
import Types exposing (..)


initialize : Phoenix.Socket.Socket Msg
initialize =
    Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
        |> Phoenix.Socket.withDebug


joinGameRoom : GameName -> Model -> ( Model, Cmd Msg )
joinGameRoom gameName model =
    let
        channel =
            "game:"
                ++ gameName
                |> Phoenix.Channel.init
                |> Phoenix.Channel.onJoin JoinedChannel
                |> Phoenix.Channel.onClose ClosedChannel
                |> Phoenix.Channel.onError ChannelError
                |> Phoenix.Channel.onJoinError JoinError

        ( joinedSocket, joinCmd ) =
            Phoenix.Socket.join channel model.socket

        joinedSocketWithCallbacks =
            joinedSocket
                |> Phoenix.Socket.on "game_start" "game:foo" GameStarted
    in
        { model | socket = joinedSocketWithCallbacks } ! [ Cmd.map GotServerMessage joinCmd ]


listenSubscription : Phoenix.Socket.Socket Msg -> Sub Msg
listenSubscription socket =
    Phoenix.Socket.listen socket GotServerMessage
