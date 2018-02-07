module State exposing (init, update, subscriptions)

import Json.Decode as JD


-- Our imports

import GameSocket
import Types exposing (..)
import Data exposing (..)


init : ( Model, Cmd Msg )
init =
    { gameName = "foo"
    , socket = GameSocket.initialize
    , debugMessages = [ "Joining game room!" ]
    , playingAs = Unassigned
    , gameState = NotStarted
    }
        |> GameSocket.joinGameRoom



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        JoinedChannel response ->
            ( updatePlayingAs model response, Cmd.none )

        JoinError response ->
            ( model |> appendMessage ("Joining channel failed with message " ++ toString response), Cmd.none )

        ChannelError response ->
            ( model |> appendMessage ("ChannelError " ++ toString response), Cmd.none )

        GameStarted game ->
            ( { model | gameState = Running game }, Cmd.none )

        GameUpdate game ->
            ( { model | gameState = Running game }, Cmd.none )

        GameEnd outcome board ->
            ( { model | gameState = Ended outcome board }, Cmd.none )

        DecodeError errorMessage ->
            ( model |> appendMessage ("Decode error:" ++ toString errorMessage), Cmd.none )

        PlayTurn coordinate ->
            GameSocket.sendPlayMessage model coordinate

        _ ->
            model ! []


appendMessage : String -> Model -> Model
appendMessage message model =
    { model | debugMessages = message :: model.debugMessages }


updatePlayingAs : Model -> JD.Value -> Model
updatePlayingAs model value =
    case JD.decodeValue playingAsDecoder value of
        Ok player ->
            { model | playingAs = AssignedPlayer player }

        Err message ->
            appendMessage message model



---- SUBS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    GameSocket.listenSubscription model.socket



---- PROGRAM ----
