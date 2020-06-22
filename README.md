# List-based parser combinator library in Raku

This libraru provides the following parser combinators:

```
    sequence,
    choice,
    try,
    maybe,
    regex,
    parens,
    char,
    sepBy,
    sepByChar,
    oneOf,
    word,
    mixedCaseWord,
    natural,
    symbol,
    apply,
    greedyUpto,
    upto,
    many,
    many1,
    whiteSpace,
    comma,
    semi
```

These combinators behave very much like their counterparts in the Haskell Parsec library, so for a description please see this [review of combinators](http://jakewheat.github.io/intro_to_parsing/#combinator-review). 

There are a few parsers that do not occur in the original Parsec library:

- `many`: like `many1` but can match 0 times
- `regex`: tries to parse whatever regular expression you provide it
- `upto`:  tries to parse whatever regular expression you provide it, but from the start of the string and in a non-greedy way
- `greedyUpto`:  tries to parse whatever regular expression you provide it, but from the start of the string, in a greedy way
- `word`: an alias for `identifier`
- `mixedCaseWord`: identifiers must start with a lowercase letter, this one accepts an uppercase as well. 

The library also provides the `apply` function to run a parser on a string and the `unmtup` function to unpack the result in a `(status, remaining string, parse tree)` tuple. 
Parsers can be labeled with the `tag` function and the tagged matches can be returned by calling `getParseTree` on the parse tree.

See [this explanation](https://wimvanderbauwhede.github.io/articles/list-based-parser-combinators/) for more details.

    

