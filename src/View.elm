module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)


--- Our imports

import Types exposing (..)


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
