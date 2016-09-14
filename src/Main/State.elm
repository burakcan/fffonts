module Main.State exposing (update, init, subscriptions)

import Main.Routing
    exposing
        ( hopConfig
        , urlParser
        , urlUpdate
        , setQueryCmd
        , navigateToCmd
        , goBackCmd
        , goForwardCmd
        )
import Main.Types exposing (Msg(..), Model, Route(..), Flags)
import FontList.State as FontList
import Hop.Types exposing (Address)
import Keyboard


init : Flags -> ( Route, Address ) -> ( Model, Cmd Msg )
init flags ( route, address ) =
    let
        ( fontListModel, fontListCmd ) =
            FontList.init flags ( route, address )
    in
        ( Model
            { route = route
            , address = address
            }
            { sidebar = False
            }
            flags
            fontListModel
        , Cmd.batch
            [ Cmd.map FontListMsg fontListCmd
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FontListMsg msg ->
            let
                ( fontList, cmd ) =
                    FontList.update msg model
            in
                ( { model | fontList = fontList }, Cmd.map FontListMsg cmd )

        GoBack ->
            ( model, goBackCmd )

        GoForward ->
            ( model, goForwardCmd )

        NavigateTo path ->
            ( model, navigateToCmd path )

        SetQuery query ->
            ( model, setQueryCmd query model.routing.address )

        ToggleSidebar ->
            let
                ui =
                    model.ui

                newUi =
                    { ui | sidebar = not ui.sidebar }
            in
                ( { model | ui = newUi }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        escKey =
            if model.ui.sidebar then
                Keyboard.downs
                    (\code ->
                        if code == 27 then
                            ToggleSidebar
                        else
                            NoOp
                    )
            else if model.routing.route == FontDetailRoute then
                Keyboard.downs
                    (\code ->
                        if code == 27 then
                            NavigateTo "/"
                        else
                            NoOp
                    )
            else
                Sub.none
    in
        Sub.batch
            [ escKey
            , Sub.map FontListMsg <| FontList.subscriptions model
            ]
