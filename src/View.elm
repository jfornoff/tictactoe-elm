module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


--- Our imports

import Types exposing (..)


view : Model -> Html Msg
view model =
    div []
        [ h1 []
            [ text "TIC TAC TOE" ]
        , div
            [ id "viewContainer" ]
            [ div [ class "viewArea" ]
                [ viewJoinStatus model.joinStatus
                , maybeViewGame model.joinStatus
                ]
            , div [ class "viewArea" ]
                [ viewConsole model
                , viewChannelInput
                ]
            ]
        ]


viewChannelInput : Html Msg
viewChannelInput =
    div [ id "channelForm" ] [ input [ type_ "text", onInput UpdateGameNameInput ] [], button [ onClick JoinGame ] [ text "Join Game" ] ]


viewConsole : Model -> Html Msg
viewConsole model =
    div []
        [ h2 [] [ text "Console" ]
        , div [ id "console" ] <| (model.debugMessages |> List.reverse |> List.map viewDebugMessage)
        ]


viewDebugMessage : String -> Html Msg
viewDebugMessage message =
    div [] [ text message ]


viewJoinStatus : JoinStatus -> Html Msg
viewJoinStatus joinStatus =
    case joinStatus of
        NotJoined ->
            h3 [] [ text "Join a game, let's go!" ]

        Joining ->
            h3 [] [ text "Trying to join..." ]

        Joined playingAs _ ->
            viewPlayingAs playingAs


maybeViewGame : JoinStatus -> Html Msg
maybeViewGame joinStatus =
    let
        gameContent =
            case joinStatus of
                NotJoined ->
                    div [] []

                Joining ->
                    div [] []

                Joined playingAs gameState ->
                    viewGame gameState playingAs
    in
        div [ id "gameContent" ] [ gameContent ]


viewGame : GameState -> PlayingAs -> Html Msg
viewGame gameState playingAs =
    case gameState of
        WaitingForStart ->
            h3 [] [ text "Waiting for game start..." ]

        Running game ->
            div []
                [ viewBoard game.board
                ]

        Ended outcome board ->
            div []
                [ viewBoard board
                , viewOutcome outcome playingAs
                ]


viewOutcome : Outcome -> PlayingAs -> Html Msg
viewOutcome outcome (PlayingAs player) =
    let
        displayValue =
            case outcome of
                Draw ->
                    "It's a draw! :o"

                PlayerWon winner ->
                    if player == winner then
                        "You won! Congrats, you won a kids game."
                    else
                        "Oh man, you lost. Better luck next time!"
    in
        h2 [ id "outcome" ] [ text displayValue ]


viewPlayingAs : PlayingAs -> Html Msg
viewPlayingAs playingAs =
    let
        displayValue =
            case playingAs of
                PlayingAs X ->
                    "You're playing X"

                PlayingAs O ->
                    "You're playing O"
    in
        h2 [] [ text displayValue ]


viewBoard : Board -> Html Msg
viewBoard board =
    table [ id "board" ]
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
