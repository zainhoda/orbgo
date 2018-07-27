module Orbgo exposing (..)

import Debug exposing (log)
import EveryDict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html5.DragDrop as DragDrop


type Position
    = Row
    | Column
    | Measure
    | Images
    | Filters
    | NoPosition


type DataType
    = Object
    | Int64
    | Float64
    | Bool64
    | DateTime64
    | TimeDelta
    | Category


type alias Model =
    { availableFields : List ( String, DataType )
    , fieldsPositioned : EveryDict.EveryDict Position (List String)
    , dragDrop : DragDrop.Model String Position
    }


type Msg
    = DragDropMsg (DragDrop.Msg String Position)


model : Model
model =
    { availableFields =
        [ ( "local_date", Object )
        , ( "brand", Object )
        , ( "dma", Object )
        , ( "num_visits", Float64 )
        , ( "dwell_time", Int64 )
        ]
    , fieldsPositioned = EveryDict.empty
    , dragDrop = DragDrop.init
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case log "msg" msg of
        DragDropMsg msg_ ->
            let
                ( model_, result ) =
                    DragDrop.updateSticky msg_ model.dragDrop

                ( x, str ) =
                    case result of
                        Nothing ->
                            ( NoPosition, "" )

                        Just ( str, y, _ ) ->
                            ( y, str )
            in
            { model
                | dragDrop = model_
                , fieldsPositioned =
                    if str /= "" && x /= NoPosition then
                        model.fieldsPositioned
                            |> EveryDict.map
                                (\k ->
                                    \listString ->
                                        if k == x || k == NoPosition then
                                            listString
                                        else
                                            listString
                                                |> List.filter
                                                    (\s -> s /= str)
                                )
                            |> EveryDict.update x
                                (\maybeV ->
                                    case maybeV of
                                        Nothing ->
                                            Just [ str ]

                                        Just v ->
                                            Just (v ++ [ str ])
                                )
                    else
                        model.fieldsPositioned
            }
                ! []


view : Model -> Html Msg
view model =
    let
        dropId =
            DragDrop.getDropId model.dragDrop

        maybeDragId =
            DragDrop.getDragId model.dragDrop
    in
    div [ class "wrapper" ]
        [ div [ class "top_icon_bar clearfix" ]
            [ div [ class "icon_group" ]
                [ a []
                    [ img [ src "img/orbgo.svg" ]
                        []
                    ]
                ]
            , div [ class "icon_group" ]
                [ a []
                    [ i [ class "fas fa-arrow-left fa-2x" ]
                        []
                    ]
                , a []
                    [ i [ class "fas fa-arrow-right fa-2x" ]
                        []
                    ]
                , a []
                    [ i [ class "fas fa-save fa-2x" ]
                        []
                    ]
                , a []
                    [ i [ class "fas fa-sync-alt fa-2x" ]
                        []
                    ]
                ]
            , div [ class "icon_group" ]
                [ a []
                    [ i [ class "fas fa-swatchbook fa-2x" ]
                        []
                    ]
                , a []
                    [ i [ class "fas fa-sort-amount-down fa-2x" ]
                        []
                    ]
                , a []
                    [ i [ class "fas fa-sort-amount-up fa-2x" ]
                        []
                    ]
                ]
            , div [ class "icon_group" ]
                [ select [ name "" ]
                    [ option [ value "Python Code" ]
                        [ text "Python Code" ]
                    , option [ value "Output" ]
                        [ text "Output" ]
                    ]
                ]
            , div [ class "icon_group no-border flt_rt" ]
                [ a []
                    [ i [ class "fas fa-bolt fa-2x" ]
                        []
                    ]
                ]
            ]
        , div [ class "main_container" ]
            [ div [ class "col1" ]
                [ div [ class "ui-tabs ui-corner-all ui-widget ui-widget-content", id "tabs" ]
                    [ ul [ class "ui-tabs-nav ui-corner-all ui-helper-reset ui-helper-clearfix ui-widget-header", attribute "role" "tablist" ]
                        [ li [ attribute "aria-controls" "tabs-1", attribute "aria-expanded" "true", attribute "aria-labelledby" "ui-id-1", attribute "aria-selected" "true", class "ui-tabs-tab ui-corner-top ui-state-default ui-tab ui-tabs-active ui-state-active", attribute "role" "tab", attribute "tabindex" "0" ]
                            [ a [ class "ui-tabs-anchor", href "#tabs-1", id "ui-id-1", attribute "role" "presentation", attribute "tabindex" "-1" ]
                                [ text "Data" ]
                            ]
                        , li [ attribute "aria-controls" "tabs-2", attribute "aria-expanded" "false", attribute "aria-labelledby" "ui-id-2", attribute "aria-selected" "false", class "ui-tabs-tab ui-corner-top ui-state-default ui-tab", attribute "role" "tab", attribute "tabindex" "-1" ]
                            [ a [ class "ui-tabs-anchor", href "#tabs-2", id "ui-id-2", attribute "role" "presentation", attribute "tabindex" "-1" ]
                                [ text "Analytics" ]
                            ]
                        ]
                    , div [ attribute "aria-hidden" "false", attribute "aria-labelledby" "ui-id-1", class "ui-tabs-panel ui-corner-bottom ui-widget-content", id "tabs-1", attribute "role" "tabpanel", attribute "style" "display: block;" ]
                        [ div [ class "tabs_container_1" ]
                            [ div [ class "db_name" ]
                                [ text "data" ]
                            , div [ class "heading" ]
                                [ div [ class "heading_text" ]
                                    [ text "Dimensions" ]
                                , div [ class "icons" ]
                                    [ a []
                                        [ i [ class "fas fa-th-list" ]
                                            []
                                        ]
                                    , a []
                                        [ i [ class "fas fa-search" ]
                                            []
                                        ]
                                    ]
                                ]
                            , viewDiv NoPosition model.fieldsPositioned maybeDragId dropId
                            ]
                        , div [ class "tabs_container_2" ]
                            [ div [ class "heading" ]
                                [ text "Measures" ]
                            , ul []
                                [ li []
                                    [ a []
                                        [ text "Probability" ]
                                    ]
                                , li []
                                    [ a []
                                        [ text "Visit Count" ]
                                    ]
                                , li []
                                    [ a []
                                        [ text "Number of Records" ]
                                    ]
                                , li []
                                    [ a []
                                        [ text "Measure Values" ]
                                    ]
                                ]
                            ]
                        ]
                    , div [ attribute "aria-hidden" "true", attribute "aria-labelledby" "ui-id-2", class "ui-tabs-panel ui-corner-bottom ui-widget-content", id "tabs-2", attribute "role" "tabpanel", attribute "style" "display: none;" ]
                        [ p []
                            [ text "Morbi tincidunt, dui sit amet facilisis feugiat, odio metus gravida ante, ut pharetra massa metus id nunc. Duis scelerisque molestie turpis. Sed fringilla, massa eget luctus malesuada, metus eros molestie lectus, ut tempus eros massa ut dolor. Aenean aliquet fringilla sem. Suspendisse sed ligula in ligula suscipit aliquam. Praesent in eros vestibulum mi adipiscing adipiscing. Morbi facilisis. Curabitur ornare consequat nunc. Aenean vel metus. Ut posuere viverra nulla. Aliquam erat volutpat. Pellentesque convallis. Maecenas feugiat, tellus pellentesque pretium posuere, felis lorem euismod felis, eu ornare leo nisi vel felis. Mauris consectetur tortor et purus." ]
                        ]
                    ]
                ]
            , div [ class "col2" ]
                [ div [ class "content_box" ]
                    [ div [ class "title" ]
                        [ text "Images" ]
                    , viewDiv Images model.fieldsPositioned maybeDragId dropId
                    ]
                , div [ class "content_box" ]
                    [ div [ class "title" ]
                        [ text "Filters" ]
                    , viewDiv Filters model.fieldsPositioned maybeDragId dropId
                    ]
                , div [ class "content_box" ]
                    [ div [ class "title" ]
                        [ text "Values" ]
                    , div [ class "" ]
                        [ select [ name "marks" ]
                            [ option [ value "Automatic" ]
                                [ text "Automatic" ]
                            , option [ value "Option 2" ]
                                [ text "Option 2" ]
                            , option [ value "Option 3" ]
                                [ text "Option 3" ]
                            ]
                        ]
                    , viewDiv Measure model.fieldsPositioned maybeDragId dropId
                    ]
                ]
            , div [ class "col3" ]
                [ div [ class "col3_top_bar columns" ]
                    [ div [ class "left_portion" ]
                        [ div [ class "title" ]
                            [ text "Columns" ]
                        ]
                    , div [ class "right_portion" ]
                        [ viewDiv Column model.fieldsPositioned maybeDragId dropId ]
                    ]
                , div [ class "col3_top_bar rows" ]
                    [ div [ class "left_portion" ]
                        [ div [ class "title" ]
                            [ text "Rows" ]
                        ]
                    , div [ class "right_portion" ]
                        [ viewDiv Row model.fieldsPositioned maybeDragId dropId ]
                    ]
                , div [ class "col3_contentarea" ]
                    [ span [ style [ ( "font-family", "monospace" ) ] ]
                        [ text
                            (let
                                getCols position =
                                    EveryDict.get position model.fieldsPositioned |> Maybe.withDefault []
                             in
                             "data.pivot_table(index="
                                ++ toString (getCols Row)
                                ++ ", columns="
                                ++ toString (getCols Column)
                                ++ ", values="
                                ++ toString (getCols Measure)
                                ++ ", aggfunc=np.sum, fill_value=0)"
                            )
                        ]
                    ]
                ]
            ]
        , div [ class "footer" ]
            [ div [ class "footer1" ]
                [ a []
                    [ text "Data Source" ]
                , a []
                    [ text "Sheet 1" ]
                , a []
                    [ img [ src "images/footer1.jpg" ]
                        []
                    ]
                , a []
                    [ img [ src "images/footer2.jpg" ]
                        []
                    ]
                , a []
                    [ img [ src "images/footer3.jpg" ]
                        []
                    ]
                ]
            , div [ class "footer2" ]
                [ div [ class "footer_icons_group" ]
                    [ a []
                        [ img [ src "images/footer8.jpg" ]
                            []
                        ]
                    , a []
                        [ img [ src "images/footer9.jpg" ]
                            []
                        ]
                    , a []
                        [ img [ src "images/footer10.jpg" ]
                            []
                        ]
                    ]
                , div [ class "footer_icons_group" ]
                    [ a []
                        [ img [ src "images/footer4.jpg" ]
                            []
                        ]
                    , a []
                        [ img [ src "images/footer5.jpg" ]
                            []
                        ]
                    , a []
                        [ img [ src "images/footer6.jpg" ]
                            []
                        ]
                    , a []
                        [ img [ src "images/footer7.jpg" ]
                            []
                        ]
                    ]
                ]
            ]
        ]


isNothing : Maybe a -> Bool
isNothing maybe =
    case maybe of
        Just _ ->
            False

        Nothing ->
            True


viewDiv : Position -> EveryDict.EveryDict Position (List String) -> Maybe String -> Maybe Position -> Html Msg
viewDiv position d maybeDragId dropId =
    let
        currentColumns =
            EveryDict.get position d |> Maybe.withDefault []

        highlight =
            if dropId |> Maybe.map ((==) position) |> Maybe.withDefault False then
                [ style [ ( "background-color", "cyan" ) ] ]
            else
                []

        alreadyAtCurrentPosition =
            maybeDragId
                |> Maybe.map (\x -> List.member x currentColumns)
                |> Maybe.withDefault False
    in
    ul
        (highlight
            ++ (if not alreadyAtCurrentPosition || position == NoPosition then
                    DragDrop.droppable DragDropMsg position
                else
                    []
               )
        )
        (case List.length currentColumns of
            0 ->
                [ text "Drop Here" ]

            _ ->
                List.map
                    (\x ->
                        li (DragDrop.draggable DragDropMsg x ++ [ class "abc" ])
                            [ a [] [ text x ]
                            ]
                    )
                    currentColumns
        )


main : Program Never Model Msg
main =
    program
        { init =
            ( { model
                | fieldsPositioned =
                    EveryDict.insert
                        NoPosition
                        (List.map (\( a, b ) -> a) model.availableFields)
                        model.fieldsPositioned
              }
            , Cmd.none
            )
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
