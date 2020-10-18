module HelpersTests exposing (..)

import Expect
import Helpers exposing (..)
import Test exposing (..)



-- adjacent tests


decodeNumberCases =
    [ ( ( "9DB", 0, 72 ), Ok ( 3, 1365 ) )
    , ( ( "ECKWD4C7CU47R2WF", 0, 72 ), Ok ( 3, 12324 ) )
    , ( ( "ECKWD4C7CU47R2WF", 3, 17 ), Ok ( 5, 73 ) )
    , ( ( "ECKWD4C7CU47R2WF", 5, 21 ), Ok ( 7, 72 ) )
    , ( ( "ECKWD4C7CU47R2WF", 7, 20 ), Ok ( 9, 73 ) )
    , ( ( "ECKWD4C7CU47R2WF", 9, 19 ), Ok ( 13, 39160 ) )
    , ( ( "ECKWD4C7CU47R2WF", 13, 84 ), Ok ( 16, 6923 ) )
    ]


canDecodeNumber : ( ( String, Int, Int ), GeneralizedNumberResult ) -> Test
canDecodeNumber testCase =
    case testCase of
        ( ( extended, extpos, bias ), expected ) ->
            test ("Decodes number " ++ extended ++ " " ++ String.fromInt extpos) <|
                \_ -> Expect.equal (decodeGeneralizedNumber (String.toList extended) extpos bias) expected


decodeNumberTest =
    decodeNumberCases |> List.map canDecodeNumber |> describe "decode number"
