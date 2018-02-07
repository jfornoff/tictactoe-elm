module State exposing (init, update, subscriptions)

import GameSocket
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    { gameName = "foo"
    , socket = GameSocket.initialize
    , debugMessages = [ "Joining game room!" ]
    , gameState = NotStarted
    }
        |> GameSocket.joinGameRoom



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        JoinedChannel response ->
            ( model |> appendMessage "Joined channel successfully!", Cmd.none )

        JoinError response ->
            ( model |> appendMessage ("Joining channel failed with message " ++ toString response), Cmd.none )

        ChannelError response ->
            ( model |> appendMessage ("ChannelError " ++ toString response), Cmd.none )

        GameStarted game ->
            ( { model | gameState = Running game }, Cmd.none )

        DecodeError errorMessage ->
            ( model |> appendMessage ("Decode error:" ++ toString errorMessage), Cmd.none )

        PlayTurn coordinate ->
            GameSocket.sendPlayMessage model coordinate

        _ ->
            model ! []


appendMessage : String -> Model -> Model
appendMessage message model =
    { model | debugMessages = message :: model.debugMessages }



---- SUBS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    GameSocket.listenSubscription model.socket



---- PROGRAM ----
