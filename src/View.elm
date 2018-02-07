module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


--- Our imports

import Types exposing (..)


view : Model -> Html Msg
view model =
    div [ id "viewContainer" ]
        [ viewDebugMessages model
        , viewGame model
        ]


viewDebugMessages : Model -> Html Msg
viewDebugMessages model =
    div [] [ div [] <| (model.debugMessages |> List.reverse |> List.map viewDebugMessage) ]


viewDebugMessage : String -> Html Msg
viewDebugMessage message =
    div [] [ text message ]


viewGame : Model -> Html Msg
viewGame model =
    case model.gameState of
        NotStarted ->
            h1 [] [ text "Game is not started yet!" ]

        Running game ->
            div []
                [ viewPlayingAs model.playingAs
                , viewBoard game.board
                ]


viewPlayingAs : PlayingAs -> Html Msg
viewPlayingAs playingAs =
    let
        displayValue =
            case playingAs of
                Unassigned ->
                    "No side assigned yet"

                AssignedPlayer X ->
                    "You're playing X"

                AssignedPlayer O ->
                    "You're playing O"
    in
        h1 [] [ text displayValue ]


viewBoard : Board -> Html Msg
viewBoard board =
    table []
        [ viewRow board.topRow (BoardCoordinate RowOnTop)
        , viewRow board.middleRow (BoardCoordinate RowInMiddle)
        , viewRow board.bottomRow (BoardCoordinate RowOnBottom)
        ]


viewRow : BoardRow -> (CellPosition -> BoardCoordinate) -> Html Msg
viewRow row coordinateConstructor =
    tr []
        [ viewCell row.left (coordinateConstructor CellOnLeft)
        , viewCell row.middle (coordinateConstructor CellInMiddle)
        , viewCell row.right (coordinateConstructor CellOnRight)
        ]


viewCell : Cell -> BoardCoordinate -> Html Msg
viewCell cell coordinate =
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
        td [ class "cell", onClick <| PlayTurn coordinate ] [ text cellText ]
