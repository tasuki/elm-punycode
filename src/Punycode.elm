module Punycode exposing (decode, decodeIdn)

{-| [Punycode](https://en.wikipedia.org/wiki/Punycode) is a Unicode encoding used for [internationalized domain names](https://en.wikipedia.org/wiki/Internationalized_domain_name).


# Decoding

@docs decode, decodeIdn

-}

import Helpers
import String.Extra


idnPrefix =
    "xn--"


idnPrefixLen =
    String.length idnPrefix


{-| Decodes a Punycode-encoded string into Unicode.

    import Punycode

    Punycode.decode "bcher-kva" == "bücher"

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


decodeIdnPart : String -> String
decodeIdnPart idnPart =
    if String.startsWith idnPrefix idnPart then
        String.dropLeft idnPrefixLen idnPart |> decode

    else
        idnPart


{-| Decodes an internationalized domain name into Unicode.

    import Punycode

    Punycode.decodeIdn "www.xn--bcher-kva.example" == "www.bücher.example"

-}
decodeIdn : String -> String
decodeIdn =
    String.split "." >> List.map decodeIdnPart >> String.join "."
