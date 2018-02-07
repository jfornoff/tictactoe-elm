module Data exposing (..)

import Json.Decode as JD
import Types exposing (..)


decodeGameUpdate : JD.Value -> Msg
decodeGameUpdate value =
    let
        decodeResult =
            JD.decodeValue playerDecoder value
    in
        case decodeResult of
            Ok player ->
                player
                    |> Game
                    |> GameStarted

            Err message ->
                DecodeError message


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
