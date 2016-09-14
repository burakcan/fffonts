module Main.View exposing (view)

import FontList.View as FontList
import FontList.Types
import FontDetail.View as FontDetail
import Main.Types exposing (Msg(ToggleSidebar, FontListMsg, NavigateTo), Model, Route(..))
import Html exposing (Html, Attribute, div, text, button, i, input, a, nav)
import Html.App as App
import Html.Attributes exposing (class, classList, type', href)
import Html.Events exposing (onClick, onInput, onWithOptions)
import Dict exposing (Dict)
import Json.Decode as Json


view : Model -> Html Msg
view model =
    let
        favorites =
            case Dict.get "Favorites" model.fontList.buckets of
                Nothing ->
                    []

                Just favorites ->
                    favorites
    in
        div [ classList [ ( "Main", True ), ( "sidebarOpen", model.ui.sidebar ) ] ]
            [ sidebar model
            , div [ class "App" ]
                [ header model
                , if model.routing.route == FontDetailRoute then
                    FontDetail.view model favorites
                  else
                    div [] []
                , div [ class "Content" ]
                    [ App.map FontListMsg <| FontList.view model favorites ]
                ]
            ]


sidebar : Model -> Html Msg
sidebar model =
    div []
        [ div [ class "Sidebar" ] []
        , div [ class "SidebarOverlay", onClick ToggleSidebar ] []
        ]


onNavClick : Msg -> Attribute Msg
onNavClick msg =
    onWithOptions
        "click"
        { stopPropagation = True, preventDefault = True }
        (Json.succeed msg)


header : Model -> Html Msg
header model =
    div [ class "Header" ]
        [ div [ class "Logo", onNavClick <| NavigateTo "" ] [ text "fffonts" ]
        , button [ class "MenuButton", onClick ToggleSidebar ]
            [ i [ class "material-icons MenuIcon" ] [ text "menu" ]
            ]
        , div [ class "Search" ]
            [ App.map FontListMsg <|
                input
                    [ class "SearchInput"
                    , type' "text"
                    , onInput <| FontList.Types.Search
                    ]
                    []
            , i [ class "material-icons SearchIcon" ] [ text "search" ]
            ]
        , nav [ class "HeaderNavigation" ] []
        ]
