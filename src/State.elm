module State exposing (init, update, subscriptions)

import GameSocket
import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    { socket = GameSocket.initialize
    , debugMessages = [ "Joining game room!" ]
    , gameState = NotStarted
    }
        |> GameSocket.joinGameRoom "foo"



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        newModel =
            case msg of
                JoinedChannel response ->
                    model |> appendMessage "Joined channel successfully!"

                JoinError response ->
                    model |> appendMessage ("Joining channel failed with message " ++ toString response)

                ChannelError response ->
                    model |> appendMessage ("ChannelError " ++ toString response)

                GameStarted game ->
                    { model | gameState = Running game }

                DecodeError errorMessage ->
                    model |> appendMessage ("Decode error:" ++ toString errorMessage)

                _ ->
                    model
    in
        newModel ! []


appendMessage : String -> Model -> Model
appendMessage message model =
    { model | debugMessages = message :: model.debugMessages }



---- SUBS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    GameSocket.listenSubscription model.socket



---- PROGRAM ----
