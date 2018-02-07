module Main exposing (..)

import Html
import View exposing (view)


---- OUR IMPORTS ----

import Types exposing (..)
import GameSocket


---- MODEL ----


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
                    model |> appendMessage ("Joining channel failed with message " ++ (toString response))

                ChannelError response ->
                    model

                GotServerMessage _ ->
                    model

                GameStarted game ->
                    { model | gameState = Running game }

                DecodeError errorMessage ->
                    model |> appendMessage errorMessage

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


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
