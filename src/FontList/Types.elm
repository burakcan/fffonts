module FontList.Types exposing (Msg(..), Model, Font, Buckets, ListBuckets)

import Http
import Dict exposing (Dict)


type alias Buckets =
    Dict String (List String)


type alias ListBuckets =
    List ( String, List String )


type Msg
    = NoOp
    | FontsFailed Http.Error
    | FontsLoaded (List Font)
    | ItemStatus ( String, String )
    | ToggleToBucket String String
    | Search String
    | ShowDetail Font


type alias Font =
    { family : String
    , variants : List String
    , subsets : List String
    , version : String
    , files : Dict String String
    , status : String
    }


type alias Model =
    { fonts : List Font
    , sort : String
    , searchTerm : String
    , buckets : Buckets
    }
