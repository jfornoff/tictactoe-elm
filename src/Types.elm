module Types exposing (..)

import Json.Decode as JD
import Phoenix.Socket


type alias Model =
    { socket : Phoenix.Socket.Socket Msg
    , debugMessages : List String
    , gameState : GameState
    }


type GameState
    = NotStarted
    | Running Game


type Player
    = X
    | O


type alias Board =
    { topRow : BoardRow
    , middleRow : BoardRow
    , bottomRow : BoardRow
    }


type alias BoardRow =
    { left : Cell
    , middle : Cell
    , right : Cell
    }


type Cell
    = Unset
    | Set Player


type alias Game =
    { currentPlayer : Player
    , board : Board
    }


type Msg
    = NoOp
    | GotServerMessage (Phoenix.Socket.Msg Msg)
    | JoinedChannel JD.Value
    | ClosedChannel JD.Value
    | ChannelError JD.Value
    | JoinError JD.Value
    | GameStarted Game
    | DecodeError String


type alias GameName =
    String
