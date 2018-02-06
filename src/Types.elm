module Types exposing (..)

import Json.Decode as JD
import Phoenix.Socket


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    }


type Msg
    = NoOp
    | GotServerMessage (Phoenix.Socket.Msg Msg)
    | JoinedChannel JD.Value
    | ClosedChannel JD.Value
    | ChannelError JD.Value
    | JoinError JD.Value
    | GameStarted JD.Value


type alias GameName =
    String
