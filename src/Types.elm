module Types exposing (..)

import Json.Decode as JD
import Phoenix.Socket


type alias Model =
    { gameNameInput : String
    , gameName : String
    , socket : Phoenix.Socket.Socket Msg
    , debugMessages : List String
    , joinStatus : JoinStatus
    }


type Msg
    = GotServerResponse (Phoenix.Socket.Msg Msg)
    | UpdateGameNameInput String
    | JoinGame
    | JoinedChannel JD.Value
    | JoinError JD.Value
    | GameStarted Game
    | GameUpdate Game
    | GameEnd Outcome Board
    | DecodeError String
    | PlayTurn BoardCoordinate


type alias GameName =
    String


type JoinStatus
    = NotJoined
    | Joining
    | Joined PlayingAs GameState


type GameState
    = WaitingForStart
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
