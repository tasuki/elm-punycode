module Punycode exposing (decode)

import Helpers
import String.Extra


decode : String -> String
decode inputStr =
    let
        base =
            String.Extra.leftOfBack "-" inputStr

        extensionStart =
            if String.contains "-" inputStr then
                (+) 1 <| String.length base

            else
                0

        extended =
            String.dropLeft extensionStart <| String.toUpper inputStr
    in
    Helpers.insertionSort base extended
