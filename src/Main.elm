module Main exposing (..)

import Html exposing (Html, text, div, h1, img)
import Html.Attributes exposing (src)


---- OUR IMPORTS ----

import Types exposing (..)
import GameSocket


---- MODEL ----


init : ( Model, Cmd Msg )
init =
    { socket = GameSocket.initialize
    }
        |> GameSocket.joinGameRoom "foo"



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        JoinedChannel response ->
            model ! []

        JoinError response ->
            model ! []

        ChannelError response ->
            model ! []

        GotServerMessage _ ->
            model ! []

        GameStarted response ->
            model ! []

        _ ->
            model ! []



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "Your Elm App is working!" ]
        ]



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
