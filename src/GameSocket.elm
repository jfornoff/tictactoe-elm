module GameSocket exposing (..)

import Phoenix.Socket as Socket
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Json.Encode as JE


--- Our imports

import Types exposing (..)
import Data exposing (..)
import Constants exposing (socketUrl)


-- Setup


initialize : Socket.Socket Msg
initialize =
    Socket.init socketUrl


listenSubscription : Socket.Socket Msg -> Sub Msg
listenSubscription socket =
    Socket.listen socket GotServerResponse



-- Contact server


joinGameRoom : Model -> ( Model, Cmd Msg )
joinGameRoom model =
    let
        topicName =
            gameTopicName model.gameName

        channel =
            topicName
                |> Channel.init
                |> Channel.onJoin JoinedChannel
                |> Channel.onJoinError JoinError

        ( joinedSocket, joinCmd ) =
            Socket.join channel model.socket

        joinedSocketWithCallbacks =
            joinedSocket
                |> Socket.on "game_start" topicName (decodeGameUpdate GameStarted)
                |> Socket.on "game_update" topicName (decodeGameUpdate GameUpdate)
                |> Socket.on "game_end" topicName decodeGameEnd
    in
        { model | socket = joinedSocketWithCallbacks } ! [ Cmd.map GotServerResponse joinCmd ]


sendPlayMessage : Model -> BoardCoordinate -> ( Model, Cmd Msg )
sendPlayMessage model coordinate =
    let
        pushMessage =
            model.gameName
                |> gameTopicName
                |> Push.init "play"
                |> Push.withPayload (coordinatePayload coordinate)

        ( newSocket, pushCmd ) =
            Socket.push pushMessage model.socket
    in
        { model | socket = newSocket } ! [ Cmd.map GotServerResponse pushCmd ]



-- Helpers


coordinatePayload : BoardCoordinate -> JE.Value
coordinatePayload (BoardCoordinate rowPosition cellPosition) =
    JE.object
        [ ( "x", JE.int <| cellPositionToNumber cellPosition )
        , ( "y", JE.int <| rowPositionToNumber rowPosition )
        ]


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
