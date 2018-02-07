module GameSocket exposing (..)

import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Json.Encode as JE


--- Our imports

import Types exposing (..)
import Data exposing (..)
import Constants exposing (socketUrl)


initialize : Socket.Socket Msg
initialize =
    socketUrl
        |> Socket.init
        |> Socket.withDebug


joinGameRoom : Model -> ( Model, Cmd Msg )
joinGameRoom model =
    let
        channel =
            model.gameName
                |> gameTopicName
                |> Channel.init
                |> Channel.onJoin JoinedChannel
                |> Channel.onClose ClosedChannel
                |> Channel.onError ChannelError
                |> Channel.onJoinError JoinError

        ( joinedSocket, joinCmd ) =
            Socket.join channel model.socket

        joinedSocketWithCallbacks =
            joinedSocket
                |> Socket.on "game_start" (gameTopicName model.gameName) (decodeGameUpdate GameStarted)
                |> Socket.on "game_update" (gameTopicName model.gameName) (decodeGameUpdate GameUpdate)
                |> Socket.on "game_end" (gameTopicName model.gameName) decodeGameEnd
    in
        { model | socket = joinedSocketWithCallbacks } ! [ Cmd.map GotServerMessage joinCmd ]


sendPlayMessage : Model -> BoardCoordinate -> ( Model, Cmd Msg )
sendPlayMessage model (BoardCoordinate rowPosition cellPosition) =
    let
        ( newSocket, pushCmd ) =
            Push.init "play" (gameTopicName model.gameName)
                |> Push.withPayload (JE.object [ ( "x", JE.int <| cellPositionToNumber cellPosition ), ( "y", JE.int <| rowPositionToNumber rowPosition ) ])
                |> (flip Socket.push) model.socket
    in
        { model | socket = newSocket } ! [ Cmd.map GotServerMessage pushCmd ]


listenSubscription : Socket.Socket Msg -> Sub Msg
listenSubscription socket =
    Socket.listen socket GotServerMessage


gameTopicName : GameName -> String
gameTopicName gameName =
    "game:" ++ gameName


rowPositionToNumber : RowPosition -> Int
rowPositionToNumber position =
    case position of
        RowOnBottom ->
            0

        RowInMiddle ->
            1

        RowOnTop ->
            2


cellPositionToNumber : CellPosition -> Int
cellPositionToNumber cellPosition =
    case cellPosition of
        CellOnLeft ->
            0

        CellInMiddle ->
            1

        CellOnRight ->
            2
