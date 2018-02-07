module Types exposing (..)

import Json.Decode as JD
import Phoenix.Socket


type alias Model =
    { gameName : String
    , playingAs : PlayingAs
    , socket : Phoenix.Socket.Socket Msg
    , debugMessages : List String
    , gameState : GameState
    }


type Msg
    = NoOp
    | GotServerMessage (Phoenix.Socket.Msg Msg)
    | JoinedChannel JD.Value
    | ClosedChannel JD.Value
    | ChannelError JD.Value
    | JoinError JD.Value
    | GameStarted Game
    | GameUpdate Game
    | GameEnd Outcome Board
    | DecodeError String
    | PlayTurn BoardCoordinate


type alias GameName =
    String


type GameState
    = NotStarted
    | Running Game
    | Ended Outcome Board


type Outcome
    = Draw
    | PlayerWon Player


type PlayingAs
    = Unassigned
    | AssignedPlayer Player


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


type BoardCoordinate
    = BoardCoordinate RowPosition CellPosition


type RowPosition
    = RowOnTop
    | RowInMiddle
    | RowOnBottom


type CellPosition
    = CellOnLeft
    | CellInMiddle
    | CellOnRight


type Cell
    = Unset
    | Set Player


type alias Game =
    { currentPlayer : Player
    , board : Board
    }
