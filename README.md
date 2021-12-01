# Advent of Code 2021

In case you don't know what Advent of Code is, check https://adventofcode.com/2021/about .

## Running and testing

Inputs can be found under `data`, and code under `src`. To run the day01 code, for instance, use (from a shell):

`cat data/day01.txt | zig run src/day01.zig`

As you can probably notice from the line above, my implementations will read the input from `stdio`, and print results to `stderr`.

You can also run tests on any day by using:

`zig test src/day01.zig`

Tests use the data samples given in the description of the problem to be solved for each day.

## Setup

I'm using a development build of Zig, namely version `0.9.0-dev.1801+a4aff36fb`, running on Linux.

## Zig? What's that?

Zig is a pretty cool new language with some very interesting design decisions. Think of it as a "better C". Want to know more about it? Well, here's what you can do:

* visit https://ziglang.org
* check https://ziglearn.org/
* for a more "hands-on" approach, check https://github.com/ratfactor/ziglings

That's all. Cheers!