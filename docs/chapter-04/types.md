# Types

source lang support following data types: `nil`, `bool`, `int`, `float`, `str`, `arr`, `dict`, `error`, `fun`, `type`. `int` is a 64-bit signed integer, `float` is 64-bit floating point value, `str` is immutable char array

| Type       | Syntax                  | Comments                        |
| ---------- | ----------------------- | ------------------------------- |
| **nil**    | nil                     |                                 |
| **bool**   | `true` `false`          |                                 |
| **int**    | `0` `55` `-10`          |                                 |
| **float**  | `0.0` `55.55`           |                                 |
| **str**    | `\"Hello\"` `"hey\n"`   |                                 |
| **arr**    | `[]` `[1, true, "hey"]` |                                 |
| **dict**   | `{}` `{"a": 5}`         | also work as source object      |
| **type**   | `int` `str`             | holds the type info of value    |
| **buffer** | `[buffer(5)]`           | byte array of size holding data |
| **fun**    |                         | holds the source lambda methods |

## Operation supported on type

| Type       | Supported Operator                                                   | comment                        |
| ---------- | -------------------------------------------------------------------- | ------------------------------ |
| **nil**    | `==` `!=`                                                            |                                |
| **bool**   | `==` `!=` `&&` `!` `\|\|`                                            |                                |
| **int**    | `+` `-` `*` `/` `==` `!=` `<` `>` `>=` `<=` `&&` `!` `\|\|` `&` `\|` |                                |
| **float**  | `+` `-` `*` `/` `==` `!=` `<` `>` `>=` `<=` `&&` `!` `\|\|`          |                                |
| **str**    | `+` `-` `==` `!=` `<` `>` `:` `[]` `.`                               | `-` will pop up the last char  |
| **arr**    | `+` `-` `==` `!=` `<` `>` `:` `[]` `.`                               | '==' will compare the elements |
| **dict**   | `+` `<` `>` `[]` `.`                                                 |                                |
| **type**   | `==` `!=`                                                            |                                |
| **buffer** | `<` `>`                                                              |                                |
| **fun**    |                                                                      |                                |
