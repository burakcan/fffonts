module FontDetail.View exposing (view)

import Main.Types as Main
import FontList.State exposing (fontFromFamily)
import FontList.Types exposing (Font, Msg(ToggleToBucket))
import Html exposing (Html, div, text, h3, button, i)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Html.App as App
import Maybe exposing (andThen)
import Dict
import List
import String


view : Main.Model -> List String -> Html Main.Msg
view model favorites =
    let
        font =
            Dict.get "family" model.routing.address.query
                `andThen` fontFromFamily model.fontList.fonts
    in
        div []
            [ div [ class "FontDetailOverlay", onClick <| Main.NavigateTo "/" ] []
            , case font of
                Nothing ->
                    loading

                Just font ->
                    if font.status == "loading" then
                        loading
                    else
                        detail font favorites
            ]


loading : Html Main.Msg
loading =
    div [ class "FontDetailLoading" ] []


detail : Font -> List String -> Html Main.Msg
detail font favorites =
    let
        initial =
            String.left 1 font.family

        glyph =
            (String.toUpper initial) ++ (String.toLower initial)
    in
        div [ class "FontDetail", style [ ( "fontFamily", font.family ) ] ]
            [ div [ class "FontListItemHeader FontDetailHeader" ]
                [ h3 [] [ text font.family ]
                , button
                    [ class "HeaderButton Favorite"
                    , onClick <| Main.FontListMsg (ToggleToBucket "Favorites" font.family)
                    ]
                    [ if List.member font.family favorites then
                        icon "favorite"
                      else
                        icon "favorite_border"
                    ]
                ]
            , div [ class "FontDetailContent" ]
                [ div [ class "FontDetailContent-Glyph" ] [ text glyph ]
                , div [ class "Alphabet" ] <| List.map alphabet font.variants
                ]
            ]


icon : String -> Html Main.Msg
icon t =
    i [ class "material-icons" ] [ text t ]


alphabet : String -> Html Main.Msg
alphabet variant =
    div [ class "Variant", style [ ( "fontWeight", variant ) ] ]
        [ h3 [ style [ ( "fontWeight", variant ) ] ] [ text variant ]
        , text "The quick brown fox jumps over the lazy dog"
        ]
