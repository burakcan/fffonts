module Main.Routing
    exposing
        ( hopConfig
        , urlParser
        , urlUpdate
        , setQueryCmd
        , navigateToCmd
        , goBackCmd
        , goForwardCmd
        )

import Main.Types exposing (Msg(..), Model, Route(..))
import Dict exposing (Dict)
import List
import Navigation
import Hop
import UrlParser
import Hop.Types exposing (Config, Address)
import Border exposing (booleanPort)


routes : UrlParser.Parser (Route -> a) a
routes =
    UrlParser.oneOf
        [ UrlParser.format HomeRoute (UrlParser.s "")
        , UrlParser.format FontDetailRoute (UrlParser.s "detail")
        ]


navigateToCmd : String -> Cmd a
navigateToCmd path =
    Hop.outputFromPath hopConfig path |> Navigation.newUrl


setQueryCmd : Dict String String -> Address -> Cmd a
setQueryCmd query address =
    address
        |> Hop.setQuery query
        |> Hop.output hopConfig
        |> Navigation.newUrl


goBackCmd : Cmd a
goBackCmd =
    Navigation.back 1


goForwardCmd : Cmd a
goForwardCmd =
    Navigation.forward 1


urlUpdate : ( Route, Address ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( route, address ) model =
    ( { model
        | routing =
            { route = route
            , address = address
            }
      }
    , Cmd.none
    )


hopConfig : Config
hopConfig =
    { hash = False
    , basePath = ""
    }


urlParser : Navigation.Parser ( Route, Address )
urlParser =
    let
        parse path =
            path
                |> UrlParser.parse identity routes
                |> Result.withDefault NotFoundRoute

        resolver =
            Hop.makeResolver hopConfig parse
    in
        Navigation.makeParser (.href >> resolver)
