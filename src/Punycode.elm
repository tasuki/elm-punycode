module Punycode exposing (decode)

{-| [Punycode](https://en.wikipedia.org/wiki/Punycode) is a Unicode encoding used for [internationalized domain names](https://en.wikipedia.org/wiki/Internationalized_domain_name).

So far we have a decoder - if you'd like an encoder as well, please open an issue on GitHub!

    import Punycode

    Punycode.decode "bcher-kva" == "bücher"


# Decoding

@docs decode

-}

import Helpers
import String.Extra


{-| Decodes a Punycode-encoded string into Unicode.
-}
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
