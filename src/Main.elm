module Main exposing (..)

import Main.Types exposing (Flags)
import Main.View exposing (view)
import Main.State exposing (init, update, subscriptions)
import Main.Routing exposing (urlParser, urlUpdate)
import Navigation


main : Program Flags
main =
    Navigation.programWithFlags urlParser
        { view = view
        , init = init
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }
