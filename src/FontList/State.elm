module FontList.State exposing (update, init, subscriptions, searchable, fontFromFamily)

import Border exposing (stringListPort, booleanPort, itemStatusPort, persistBuckets)
import Main.Types as Main
import Main.Routing exposing (navigateToCmd)
import FontList.Types exposing (Msg(..), Model, Font, Buckets)
import Hop.Types exposing (Address, Query)
import Json.Decode as Json
import Json.Encode
import Maybe exposing (andThen)
import Regex exposing (HowMany(All))
import String
import Dict exposing (Dict)
import List
import Http
import Task


init : Main.Flags -> ( Main.Route, Address ) -> ( Model, Cmd Msg )
init flags ( route, address ) =
    ( { fonts = []
      , sort = ""
      , searchTerm = ""
      , buckets = Dict.fromList flags.buckets
      }
    , Cmd.batch
        [ loadFonts flags.apiBase "popularity"
        ]
    )


update : Msg -> Main.Model -> ( Model, Cmd Msg )
update msg model =
    let
        { fontList, routing } =
            model
    in
        case msg of
            NoOp ->
                ( fontList, Cmd.none )

            ShowDetail { family, status, variants } ->
                let
                    loadCmd =
                        if status == "failed" then
                            Cmd.none
                        else
                            stringListPort
                                ( "elm_loadFontWithVariants"
                                , family :: variants
                                )

                    navigateCmd =
                        if status == "failed" then
                            Cmd.none
                        else
                            navigateToCmd <| "detail?family=" ++ family

                    cmd =
                        Cmd.batch
                            [ loadCmd
                            , navigateCmd
                            ]
                in
                    ( fontList, cmd )

            FontsFailed error ->
                ( fontList, Cmd.none )

            FontsLoaded fonts ->
                let
                    ( _, loadWithVariants ) =
                        case fontFromQuery fonts routing.address.query of
                            Nothing ->
                                ( fontList, Cmd.none )

                            Just font ->
                                update (ShowDetail font) model
                in
                    ( { fontList
                        | fonts = fonts
                      }
                    , Cmd.batch
                        [ stringListPort ( "elm_fontsLoaded", List.map (\font -> font.family) fonts )
                        , loadWithVariants
                        ]
                    )

            ItemStatus ( family, status ) ->
                let
                    fonts =
                        List.map
                            (\font ->
                                if font.family == family then
                                    { font | status = status }
                                else
                                    font
                            )
                            fontList.fonts
                in
                    ( { fontList | fonts = fonts }, Cmd.none )

            Search value ->
                ( { fontList | searchTerm = searchable value }
                , stringListPort
                    ( "elm_search"
                    , List.filterMap
                        (\font ->
                            if String.contains value <| searchable font.family then
                                Just font.family
                            else
                                Nothing
                        )
                        fontList.fonts
                    )
                )

            ToggleToBucket bucket family ->
                let
                    buckets =
                        toggleToBucket bucket family fontList.buckets
                in
                    ( { fontList | buckets = buckets }
                    , persistBuckets ( "elm_persistBuckets", Dict.toList buckets )
                    )


subscriptions : Main.Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ itemStatusPort ItemStatus
        ]


toggleToBucket : String -> String -> Buckets -> Buckets
toggleToBucket bucket family buckets =
    Dict.update
        bucket
        (\field ->
            case field of
                Nothing ->
                    Just [ family ]

                Just items ->
                    if List.member family items then
                        Just (List.filter (\item -> item /= family) items)
                    else
                        Just <| family :: items
        )
        buckets


loadFonts : String -> String -> Cmd Msg
loadFonts apiBase sort =
    let
        url =
            apiBase ++ "&sort=" ++ sort
    in
        Task.perform
            FontsFailed
            FontsLoaded
            (Http.get decodeFonts url)


decodeFonts : Json.Decoder (List Font)
decodeFonts =
    Json.at [ "items" ] <| Json.list decodeFontItem


decodeFontItem : Json.Decoder Font
decodeFontItem =
    Json.object6 Font
        (Json.at [ "family" ] Json.string)
        (Json.at [ "variants" ] <| Json.list Json.string)
        (Json.at [ "subsets" ] <| Json.list Json.string)
        (Json.at [ "version" ] Json.string)
        (Json.at [ "files" ] <| Json.dict Json.string)
        (Json.succeed "waiting")


searchable : String -> String
searchable value =
    String.toLower <|
        Regex.replace All (Regex.regex "[ ]") (always "") value


fontFromFamily : List Font -> String -> Maybe Font
fontFromFamily fonts family =
    List.head <|
        List.filter
            (\font -> font.family == family)
            fonts


fontFromQuery : List Font -> Query -> Maybe Font
fontFromQuery fonts query =
    Dict.get "family" query
        `andThen` fontFromFamily fonts
