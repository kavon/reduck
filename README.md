reduck
======

A little tool that finds the beta normal form (β-nf) of a lambda term step-by-step. The evaluation strategy is to find the leftmost application of a lambda abstraction to some term and apply the β-rule. I don't have a proof (at the moment) that this will always find a β-nf if it exists.

## Building

You'll need either [MLton](http://mlton.org) or [SML/NJ](http://www.smlnj.org) installed. Using MLton, you can just run `make` in the top level directory to build an independent binary, and if you're using SML/NJ, run `sml src/code.sml` from that same directory.

## Syntax

    <lambda-term> ::= <variable>
                  ::= (\<variable>.<lambda-term>)       abstraction
                  ::= (<lambda-term> <lambda-term>)     application

    <variable>    ::= [a-zA-Z]

## Example

TODO

