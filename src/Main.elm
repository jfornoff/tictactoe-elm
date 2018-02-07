module Main exposing (..)

import Html exposing (..)


---- OUR IMPORTS ----

import Types exposing (..)
import GameSocket


---- MODEL ----


init : ( Model, Cmd Msg )
init =
    { socket = GameSocket.initialize
    , messages = [ "Joining game room!" ]
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

                _ ->
                    model
    in
        newModel ! []


appendMessage : String -> Model -> Model
appendMessage message model =
    { model | messages = message :: model.messages }



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text <| "Current game state: " ++ toString model.gameState ]
        , ol [] <| (model.messages |> List.reverse |> List.map viewMessage)
        ]


viewMessage : String -> Html Msg
viewMessage message =
    li [] [ text message ]



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
