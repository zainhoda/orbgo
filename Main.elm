module Example exposing (..)

import Debug exposing (log)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html5.DragDrop as DragDrop


type Position
    = Row
    | Column
    | Measure
    | NoPosition


type alias Model =
    { availableFields: List String
    , rows : List String
    , columns : List String
    , measures : List String
    , dragDrop : DragDrop.Model String Position
    }


type Msg
    = DragDropMsg (DragDrop.Msg String Position)


model : Model
model =
    { availableFields = ["local_date", "brand", "dma", "num_visits", "dwell_time"]
    , rows = []
    , columns = []
    , measures = []
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
                , rows =
                    if x == Row then
                        model.rows ++ [ str ]
                    else
                        List.filter (\y -> y /= str) model.rows
                , columns =
                    if x == Column then
                        model.columns ++ [ str ]
                    else
                        List.filter (\y -> y /= str) model.columns
                , measures =
                    if x == Measure then
                        model.measures ++ [ str ]
                    else
                        List.filter (\y -> y /= str) model.measures
            }
                ! []

divStyle : Attribute msg
divStyle =
    style [ ( "border", "1px solid black" )
          , ( "padding", "50px" )
          , ( "text-align", "center" ) 
          , ( "position", "relative")
          ]


view : Model -> Html Msg
view model =
    let
        dropId =
            DragDrop.getDropId model.dragDrop

        maybeDragId =
            DragDrop.getDragId model.dragDrop
    in
    div []
        [ viewDiv NoPosition model.availableFields maybeDragId dropId
        , viewDiv Row model.rows maybeDragId dropId
        , viewDiv Column model.columns maybeDragId dropId
        , viewDiv Measure model.measures maybeDragId dropId
        , pre [] [text ("data.pivot_table(index="++ (toString model.rows) ++",columns="++ (toString model.columns) ++", values="++ (toString model.measures) ++", aggfunc=np.sum, fill_value=0)" )]
        ]

isNothing : Maybe a -> Bool
isNothing maybe =
    case maybe of
        Just _ ->
            False

        Nothing ->
            True


viewDiv : Position -> List String -> Maybe String -> Maybe Position -> Html Msg
viewDiv position currentColumns maybeDragId dropId =
    let
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
    div
        (divStyle
            :: highlight
            ++ (if not alreadyAtCurrentPosition || position == NoPosition then
                    DragDrop.droppable DragDropMsg position
                else
                    []
               )
        )
        (
        [span [style [("position", "absolute"), ("top", "5px"), ("left", "5px")]] [text (toString position)]]
        ++(List.map
            (\x ->
                span ( (DragDrop.draggable DragDropMsg x) 
                ++ [Html.Attributes.style [("background-color", "lightblue"), ("color", "red"), ("margin", "10px"), ("padding", "10px"), ("font-weight", "bold"), ("font-family", "sans-serif"), ("border-radius", "5px")] ])
                    [ text x
                    ]
            )
            currentColumns
        )
        )

main : Program Never Model Msg
main =
    program
        { init = ( model, Cmd.none )
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
