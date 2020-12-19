# A Punycode decoder for Elm

[Punycode](https://en.wikipedia.org/wiki/Punycode) is a Unicode encoding used for [internationalized domain names](https://en.wikipedia.org/wiki/Internationalized_domain_name).

So far we have a decoder - if you'd like an encoder, [please open an issue](https://github.com/tasuki/elm-punycode/issues)!

## Install

```bash
elm install tasuki/elm-punycode
```

## Use

See the [module documentation for info on usage](https://package.elm-lang.org/packages/tasuki/elm-punycode/latest/Punycode).

## Develop

[![CI](https://github.com/tasuki/elm-punycode/workflows/CI/badge.svg?branch=master)](https://github.com/tasuki/elm-punycode/actions?query=workflow:CI)

Run tests locally with:

```bash
elm-test
```

## Release

Make changes, then:

```bash
elm bump
git commit
git tag {version}
git push --tags
elm release
```
