module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Http.Progress as Progress exposing (Progress(..))
import Time


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd a )
init =
    ( initModel, Cmd.none )



-- Model


type alias Model =
    { progress : Progress String
    , bookUrl : Maybe String
    , bookContent : String
    , cancel : Bool
    }


initModel : Model
initModel =
    { progress = Progress.None
    , bookUrl = Nothing
    , bookContent = ""
    , cancel = False
    }



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.cancel then
        Time.every Time.second (always RestartDownload)
    else
        case model.bookUrl of
            Just bookUrl ->
                Http.getString bookUrl
                    |> Progress.track bookUrl GetBookProgress

            Nothing ->
                Sub.none



-- Update


type Msg
    = NoOp
    | GetBook String
    | GetBookProgress (Progress String)
    | RestartDownload


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetBook url ->
            ( { model | bookUrl = Just url, cancel = Just url == model.bookUrl }, Cmd.none )

        GetBookProgress (Done bookContent) ->
            ( { model
                | progress = Done ""
                , bookContent = bookContent
                , bookUrl = Nothing
              }
            , Cmd.none
            )

        GetBookProgress (Fail error) ->
            ( { model
                | progress = Fail error
                , bookContent = toString error
              }
            , Cmd.none
            )

        GetBookProgress progress ->
            let
                percent =
                    progressLoaded progress
            in
            ( { model
                | progress = progress
              }
            , Cmd.none
            )

        RestartDownload ->
            ( { model | cancel = False }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div [ viewStyle ]
        [ h1 [] [ text "Elm Http.Progress example" ]
        , button [ onClick (GetBook "http://localhost:5000/txt/leviathan.txt") ] [ text "Download 1" ]
        , button [ onClick (GetBook "https://jsonplaceholder.typicode.com/photos") ] [ text "Download 2" ]
        , button [ onClick (GetBook "http://www.vizgr.org/historical-events/search.php?format=json&begin_date=-3000000&end_date=20151231&lang=en") ] [ text "Download 3" ]
        , progressView <|
            toString <|
                progressLoaded model.progress
        , bookContentView model.bookContent
        , footerView
        ]


progressView : String -> Html Msg
progressView loaded =
    div []
        [ span [] [ text "Progress: " ]
        , progress
            [ value loaded
            , Html.Attributes.max "100"
            ]
            [ text <| loaded ++ "%" ]
        , text <| loaded ++ "%"
        ]


progressLoaded : Progress String -> Int
progressLoaded progress =
    case progress of
        Some { bytes, bytesExpected } ->
            round <|
                (*) 100 <|
                    toFloat bytes
                        / toFloat bytesExpected

        Done _ ->
            100

        _ ->
            -- None or Fail case
            0


bookContentView : String -> Html Msg
bookContentView valueText =
    div []
        [ textarea
            [ value valueText
            , disabled True
            , bookContentViewStyle
            ]
            []
        ]


footerView : Html Msg
footerView =
    span []
        [ a
            [ href "https://gist.github.com/pablohirafuji/fa373d07c42016756d5bca28962008c4"
            , target "_blank"
            ]
            [ text "Source" ]
        , text " | "
        , text "Books from "
        , a
            [ href "http://www.gutenberg.org/"
            , target "_blank"
            ]
            [ text "Project Gutenberg" ]
        ]



-- Styles


viewStyle : Attribute Msg
viewStyle =
    style
        [ ( "display", "flex" )
        , ( "flex-direction", "column" )
        , ( "width", "550px" )
        , ( "margin", "0 auto" )
        , ( "font-family", "Arial" )
        ]


bookContentViewStyle : Attribute Msg
bookContentViewStyle =
    style
        [ ( "height", "400px" )
        , ( "width", "100%" )
        ]
