module Main.Types exposing (Model, Route(..), Msg(..), Flags)

import FontList.Types as FontList
import Hop.Types exposing (Address, Query)


type alias Flags =
    { apiBase : String
    , buckets : FontList.ListBuckets
    }


type Msg
    = NavigateTo String
    | GoBack
    | GoForward
    | SetQuery Query
    | ToggleSidebar
    | FontListMsg FontList.Msg
    | NoOp


type Route
    = HomeRoute
    | FontDetailRoute
    | NotFoundRoute


type alias Routing =
    { route : Route
    , address : Address
    }


type alias UI =
    { sidebar : Bool
    }


type alias Model =
    { routing : Routing
    , ui : UI
    , flags : Flags
    , fontList : FontList.Model
    }
