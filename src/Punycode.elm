module Punycode exposing (decode, decodeIdn, encode, encodeIdn)

{-| [Punycode](https://en.wikipedia.org/wiki/Punycode) is a Unicode encoding used for [internationalized domain names](https://en.wikipedia.org/wiki/Internationalized_domain_name).


# Decoding

@docs decode, decodeIdn


# Encoding

@docs encode, encodeIdn

-}

import Helpers
import String.Extra


idnPrefix =
    "xn--"


idnPrefixLen =
    String.length idnPrefix


{-| Decodes a Punycode-encoded string into Unicode.

Attempts to follow [RFC 3492](https://www.rfc-editor.org/rfc/rfc3492).

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

Attempts to follow [RFC 3492](https://www.rfc-editor.org/rfc/rfc3492)
using the `xn--` ACE prefix for each encoded part.

    import Punycode

    Punycode.decodeIdn "www.xn--bcher-kva.example" == "www.bücher.example"

-}
decodeIdn : String -> String
decodeIdn =
    String.split "." >> List.map decodeIdnPart >> String.join "."


{-| Encodes a Unicode string into Punycode.

Attempts to follow [RFC 3492](https://www.rfc-editor.org/rfc/rfc3492).

    import Punycode

    Punycode.encode "bücher" == "bcher-kva"

-}
encode : String -> String
encode input =
    let
        codePoints =
            String.toList input |> List.map Char.toCode

        ( basicCodePoints, nonBasicCodePoints ) =
            codePoints |> List.partition (\cp -> cp < 128)

        base =
            basicCodePoints |> List.map Char.fromCode |> String.fromList
    in
    if List.isEmpty nonBasicCodePoints then
        if String.isEmpty base then
            ""
        else
            base ++ "-"

    else
        let
            encodedPart =
                Helpers.runEncoder codePoints
        in
        if String.isEmpty base then
            encodedPart
        else
            base ++ "-" ++ encodedPart


encodeIdnPart : String -> String
encodeIdnPart idnPart =
    let
        ( ascii, nonAscii ) =
            String.toList idnPart |> List.partition (\c -> Char.toCode c < 128)
    in
    if List.isEmpty nonAscii then
        idnPart

    else
        idnPrefix ++ encode idnPart


{-| Encodes an internationalized domain name into Punycode.

Attempts to follow [RFC 3492](https://www.rfc-editor.org/rfc/rfc3492)
using the `xn--` ACE prefix for each encoded part.

    import Punycode

    Punycode.encodeIdn "www.bücher.example" == "www.xn--bcher-kva.example"

-}
encodeIdn : String -> String
encodeIdn =
    String.split "." >> List.map encodeIdnPart >> String.join "."
