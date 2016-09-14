port module Border exposing (..)

import FontList.Types exposing (ListBuckets)


port stringListPort : ( String, List String ) -> Cmd msg


port booleanPort : ( String, Bool ) -> Cmd msg


port persistBuckets : ( String, ListBuckets ) -> Cmd msg


port itemStatusPort : (( String, String ) -> msg) -> Sub msg
