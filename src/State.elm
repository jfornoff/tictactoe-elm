module State exposing (init, update, subscriptions)

import Json.Decode as JD


-- Our imports

import GameSocket
import Types exposing (..)
import Data exposing (..)


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { gameNameInput = ""
    , gameName = ""
    , socket = GameSocket.initialize
    , debugMessages = []
    , joinStatus = NotJoined
    }



---- UPDATE ----


updateOnJoinedGame : Model -> (PlayingAs -> GameState -> JoinStatus) -> Model
updateOnJoinedGame model updateFn =
    case model.joinStatus of
        NotJoined ->
            model

        Joining ->
            model

        Joined playingAs gameState ->
            let
                newJoinStatus =
                    updateFn playingAs gameState
            in
                { model | joinStatus = newJoinStatus }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateGameNameInput newInputValue ->
            ( { model | gameNameInput = newInputValue }, Cmd.none )

        JoinGame ->
            { model | gameName = model.gameNameInput, joinStatus = Joining } |> GameSocket.joinGameRoom

        JoinedChannel response ->
            let
                newModel =
                    model
                        |> joinGameAs response
                        |> appendMessage "Joining game successful!"
            in
                ( newModel, Cmd.none )

        JoinError response ->
            ( model |> appendMessage ("Joining game failed with message " ++ toString response), Cmd.none )

        GameStarted game ->
            ( updateOnJoinedGame model
                (\playingAs _ -> Joined playingAs (Running game))
            , Cmd.none
            )

        GameUpdate game ->
            ( updateOnJoinedGame model
                (\playingAs _ -> Joined playingAs (Running game))
            , Cmd.none
            )

        GameEnd outcome board ->
            ( updateOnJoinedGame model
                (\playingAs _ -> Joined playingAs (Ended outcome board))
            , Cmd.none
            )

        DecodeError errorMessage ->
            ( model |> appendMessage ("Decode error:" ++ toString errorMessage), Cmd.none )

        PlayTurn coordinate ->
            GameSocket.sendPlayMessage model coordinate

        GotServerResponse _ ->
            ( model, Cmd.none )


appendMessage : String -> Model -> Model
appendMessage message model =
    { model | debugMessages = message :: model.debugMessages }


joinGameAs : JD.Value -> Model -> Model
joinGameAs value model =
    case JD.decodeValue playingAsDecoder value of
        Ok player ->
            { model | joinStatus = Joined (AssignedPlayer player) WaitingForStart }

        Err message ->
            appendMessage message model



---- SUBS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    GameSocket.listenSubscription model.socket



---- PROGRAM ----
