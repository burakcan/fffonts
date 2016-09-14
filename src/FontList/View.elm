module FontList.View exposing (view)

import Main.Types as Main
import FontList.Types exposing (Msg(..), Font, Buckets)
import FontList.State exposing (searchable)
import Html exposing (Html, div, text, h3, button, i)
import Html.Attributes exposing (class, classList, attribute, style)
import Html.Events exposing (onClick)
import Html.App as App
import Html.Keyed
import String exposing (contains)
import Maybe exposing (andThen)
import List
import Dict


view : Main.Model -> List String -> Html Msg
view model favorites =
    Html.Keyed.node "div"
        [ classList [ ( "FontList", True ) ] ]
    <|
        List.filterMap
            (item model favorites)
            model.fontList.fonts


item : Main.Model -> List String -> Font -> Maybe ( String, Html Msg )
item model favorites font =
    if not <| model.fontList.searchTerm `contains` searchable font.family then
        Nothing
    else
        Just
            ( font.family
            , div
                [ classList [ ( "FontListItem", True ), ( font.status, True ) ]
                , attribute "data-family" font.family
                ]
                [ div [ class "FontListItemHeader" ]
                    [ h3 [ onClick <| ShowDetail font ] [ text font.family ]
                    , button
                        [ class "HeaderButton Favorite"
                        , onClick <| ToggleToBucket "Favorites" font.family
                        ]
                        [ if List.member font.family favorites then
                            icon "favorite"
                          else
                            icon "favorite_border"
                        ]
                    ]
                , div
                    [ class "FontListItemContent"
                    , style [ ( "fontFamily", font.family ) ]
                    , onClick <| ShowDetail font
                    ]
                    [ text "The quick brown fox jumps over the lazy dog" ]
                ]
            )


icon : String -> Html Msg
icon t =
    i [ class "material-icons" ] [ text t ]
