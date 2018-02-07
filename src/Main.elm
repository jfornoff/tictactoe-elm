module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


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



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ id "viewContainer" ]
        [ viewDebugMessages model
        , viewGame model.gameState
        ]


viewDebugMessages : Model -> Html Msg
viewDebugMessages model =
    div [] [ div [] <| (model.debugMessages |> List.reverse |> List.map viewDebugMessage) ]


viewDebugMessage : String -> Html Msg
viewDebugMessage message =
    div [] [ text message ]


viewGame : GameState -> Html Msg
viewGame gameState =
    case gameState of
        NotStarted ->
            h1 [] [ text "Game is not started yet!" ]

        Running game ->
            div []
                [ viewBoard game.board
                ]


viewBoard : Board -> Html Msg
viewBoard board =
    table []
        [ viewRow board.topRow
        , viewRow board.middleRow
        , viewRow board.bottomRow
        ]


viewRow : BoardRow -> Html Msg
viewRow row =
    tr [] [ viewCell row.left, viewCell row.middle, viewCell row.right ]


viewCell : Cell -> Html Msg
viewCell cell =
    let
        cellText =
            case cell of
                Unset ->
                    ""

                Set X ->
                    "X"

                Set O ->
                    "O"
    in
        td [ class "cell" ] [ text cellText ]



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
