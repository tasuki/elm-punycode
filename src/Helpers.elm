module Helpers exposing
    ( runEncoder
    , insertionSort
    , decodeGeneralizedNumber
    , GeneralizedNumberResult
    )


tmin =
    1


tmax =
    26


baseConstant =
    36


skew =
    38


damp =
    700


initial_n =
    128


initial_bias =
    72


getT : Int -> Int -> Int
getT j bias =
    let
        res =
            baseConstant * (j + 1) - bias
    in
    if res < tmin then
        tmin

    else if res > tmax then
        tmax

    else
        res


type alias GeneralizedNumberResult =
    Result String ( Int, Int )


decodeGeneralizedNumberHelper : Int -> Int -> Int -> List Char -> Int -> Int -> GeneralizedNumberResult
decodeGeneralizedNumberHelper result w j extended extpos bias =
    let
        char : Maybe Char
        char =
            List.head <| List.drop extpos extended

        t : Int
        t =
            getT j bias

        toOrd : Int -> Maybe Int
        toOrd c =
            if 0x41 <= c && c <= 0x5A then
                -- A-Z
                Just (c - 0x41)

            else if 0x30 <= c && c <= 0x39 then
                -- 0-9
                Just (c - 0x16)

            else
                Nothing

        digit : Maybe Int
        digit =
            Maybe.andThen toOrd <| Maybe.map Char.toCode char

        getResult : Int -> Int -> Int -> GeneralizedNumberResult
        getResult d newPos newResult =
            if d < t then
                Ok ( newPos, newResult )

            else
                decodeGeneralizedNumberHelper
                    newResult
                    (w * (baseConstant - t))
                    (j + 1)
                    extended
                    newPos
                    bias
    in
    case digit of
        Just d ->
            getResult d (extpos + 1) (result + d * w)

        Nothing ->
            Err "borked"


decodeGeneralizedNumber : List Char -> Int -> Int -> GeneralizedNumberResult
decodeGeneralizedNumber extended extpos bias =
    decodeGeneralizedNumberHelper 0 1 0 extended extpos bias


reduceDelta : Int -> Int -> ( Int, Int )
reduceDelta delta divisions =
    if delta > ((baseConstant - tmin) * tmax) // 2 then
        reduceDelta (delta // (baseConstant - tmin)) (divisions + baseConstant)

    else
        ( delta, divisions )


adapt : Int -> Bool -> Int -> Int
adapt delta first numchars =
    let
        divisor =
            if first then
                damp

            else
                2

        intermediateDelta =
            delta // divisor + delta // divisor // numchars

        ( newDelta, divisions ) =
            reduceDelta intermediateDelta 0
    in
    divisions + ((baseConstant - tmin + 1) * newDelta // (newDelta + skew))


insertionSortHelper : List Char -> List Char -> Int -> Int -> Int -> Int -> List Char
insertionSortHelper base extended char pos bias extpos =
    let
        recurse nextpos delta =
            let
                intermediatePos =
                    pos + delta + 1

                onePlus =
                    1 + List.length base

                newChar =
                    char + (intermediatePos // onePlus)

                newPos =
                    modBy onePlus intermediatePos

                newBase =
                    List.take newPos base ++ [ Char.fromCode newChar ] ++ List.drop newPos base

                newBias =
                    adapt delta (extpos == 0) (List.length newBase)
            in
            insertionSortHelper newBase extended newChar newPos newBias nextpos
    in
    if extpos < List.length extended then
        case decodeGeneralizedNumber extended extpos bias of
            Ok ( nextpos, delta ) ->
                recurse nextpos delta

            Err _ ->
                base

    else
        base


insertionSort : String -> String -> String
insertionSort base extended =
    String.fromList <|
        insertionSortHelper
            (String.toList base)
            (String.toList extended)
            0x80
            -1
            72
            0


fromDigit : Int -> Char
fromDigit d =
    let
        fromCode c =
            Char.fromCode c
    in
    if d >= 0 && d <= 25 then
        fromCode (d + 97)

    else if d >= 26 && d <= 35 then
        fromCode (d - 26 + 48)

    else
        -- This should not be reached in Punycode
        '\u{0000}'


encodeGeneralizedNumber : Int -> Int -> String
encodeGeneralizedNumber q bias =
    let
        loop k currentQ acc =
            let
                t =
                    if k <= bias then
                        tmin
                    else if k >= bias + tmax then
                        tmax
                    else
                        k - bias
            in
            if currentQ < t then
                acc ++ String.fromList [ fromDigit currentQ ]

            else
                let
                    qMinusT =
                        currentQ - t

                    baseMinusT =
                        baseConstant - t

                    newAcc =
                        acc ++ String.fromList [ fromDigit (t + modBy baseMinusT qMinusT) ]

                    newQ =
                        qMinusT // baseMinusT
                in
                loop (k + baseConstant) newQ newAcc
    in
    loop baseConstant q ""


runEncoder : List Int -> String
runEncoder codePoints =
    let
        h =
            codePoints |> List.filter (\cp -> cp < 128) |> List.length

        inputLength =
            List.length codePoints

        mainLoop n delta bias currentH output =
            if currentH >= inputLength then
                output

            else
                let
                    m =
                        codePoints
                            |> List.filter (\cp -> cp >= n)
                            |> List.minimum
                            |> Maybe.withDefault -1
                in
                if m == -1 then
                    output

                else
                    let
                        delta_ =
                            delta + (m - n) * (currentH + 1)

                        n_ =
                            m

                        result =
                            List.foldl
                                (\cv acc ->
                                    if cv < n_ then
                                        { acc | d = acc.d + 1 }

                                    else if cv == n_ then
                                        let
                                            encoded =
                                                encodeGeneralizedNumber acc.d acc.b

                                            newBias =
                                                adapt acc.d (acc.cH == h) (acc.cH + 1)
                                        in
                                        { d = 0, b = newBias, cH = acc.cH + 1, acc = acc.acc ++ encoded }

                                    else
                                        acc
                                )
                                { d = delta_, b = bias, cH = currentH, acc = "" }
                                codePoints
                    in
                    mainLoop (n_ + 1) (result.d + 1) result.b result.cH (output ++ result.acc)
    in
    mainLoop initial_n 0 initial_bias h ""
