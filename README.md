# A Punycode decoder for Elm

[Punycode](https://en.wikipedia.org/wiki/Punycode) is a Unicode encoding used for [internationalized domain names](https://en.wikipedia.org/wiki/Internationalized_domain_name).

So far we have a decoder - if you'd like an encoder as well, please open an issue!

## Install

```bash
elm install tasuki/elm-punycode
```

## Use

```elm
import Punycode

Punycode.decode "bcher-kva" == "bücher"
```

## Develop

[![Build Status](https://travis-ci.org/tasuki/elm-punycode.svg?branch=master)](https://travis-ci.org/tasuki/elm-punycode)

Run tests with:

```bash
elm-test
```
