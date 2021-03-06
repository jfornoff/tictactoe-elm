module Data exposing (..)

import Json.Decode as JD
import Types exposing (..)


decodeGameUpdate : (Game -> Msg) -> JD.Value -> Msg
decodeGameUpdate msgConstructor value =
    let
        decodeResult =
            JD.decodeValue gameDecoder value
    in
        case decodeResult of
            Ok game ->
                msgConstructor game

            Err message ->
                DecodeError message


decodeGameEnd : JD.Value -> Msg
decodeGameEnd value =
    let
        decodeResult =
            JD.decodeValue gameEndDecoder value
    in
        case decodeResult of
            Ok gameEnd ->
                gameEnd

            Err message ->
                DecodeError message


gameEndDecoder : JD.Decoder Msg
gameEndDecoder =
    JD.map2 GameEnd outcomeDecoder boardDecoder


gameDecoder : JD.Decoder Game
gameDecoder =
    JD.map2 Game playerDecoder boardDecoder


playerDecoder : JD.Decoder Player
playerDecoder =
    JD.field "current_player" JD.string
        |> JD.andThen
            (\playerSign ->
                case playerSign of
                    "X" ->
                        JD.succeed X

                    "O" ->
                        JD.succeed O

                    _ ->
                        JD.fail <| "Unknown current_player value: " ++ toString playerSign
            )


boardDecoder : JD.Decoder Board
boardDecoder =
    JD.field "board" <|
        JD.map3 Board (JD.field "top" rowDecoder) (JD.field "middle" rowDecoder) (JD.field "bottom" rowDecoder)


rowDecoder : JD.Decoder BoardRow
rowDecoder =
    JD.map3 BoardRow
        (JD.index 0 boardCellDecoder)
        (JD.index 1 boardCellDecoder)
        (JD.index 2 boardCellDecoder)


boardCellDecoder : JD.Decoder Cell
boardCellDecoder =
    JD.string
        |> JD.andThen
            (\cellDefinition ->
                case cellDefinition of
                    "" ->
                        JD.succeed Unset

                    "X" ->
                        JD.succeed <| Set X

                    "O" ->
                        JD.succeed <| Set O

                    _ ->
                        JD.fail <| "Unknown cell value " ++ toString cellDefinition
            )


outcomeDecoder : JD.Decoder Outcome
outcomeDecoder =
    JD.field "outcome" JD.string
        |> JD.andThen
            (\outcome ->
                case outcome of
                    "Draw" ->
                        JD.succeed Draw

                    "X wins" ->
                        JD.succeed <| PlayerWon X

                    "O wins" ->
                        JD.succeed <| PlayerWon O

                    _ ->
                        JD.fail <| "Unknown outcome " ++ (toString outcome)
            )


playingAsDecoder : JD.Decoder Player
playingAsDecoder =
    JD.field "playing_as" JD.string
        |> JD.andThen
            (\playingAs ->
                case playingAs of
                    "X" ->
                        JD.succeed X

                    "O" ->
                        JD.succeed O

                    _ ->
                        JD.fail ("Unknown playing_as value: " ++ playingAs)
            )
