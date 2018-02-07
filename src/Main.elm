module Main exposing (..)

import Html
import View exposing (view)


---- OUR IMPORTS ----

import Types exposing (..)
import State exposing (init, update, subscriptions)


---- MODEL ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
