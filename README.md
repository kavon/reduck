reduck
======

A tool that can find the [beta normal form](http://en.wikipedia.org/wiki/Beta_normal_form) (β-nf) of a term in the lambda calculus step-by-step. It's basically an interpreter for an abstract functional programming language that shows each computational step during evaluation. The evaluation strategy is *call by name*, that is, it performs a substitution (β-rule) of the argument in the function without evaluating it, and it chooses the left-most application at each step.

It additionally has a mode that can perform a [continuation-passing style](http://en.wikipedia.org/wiki/Continuation-passing_style) (CPS) transform on a lambda term.

#### Building

You'll need either [MLton](http://mlton.org) or [SML/NJ](http://www.smlnj.org) installed. Using MLton, you can just run `make` in the top level directory to build an independent binary, and if you're using SML/NJ, run `sml src/code.sml` from that same directory.

#### Syntax & Usage

    <lambda-term> ::= <variable>
                  ::= (\<variable>.<lambda-term>)       λ-abstraction
                  ::= (<lambda-term> <lambda-term>)     application

    <variable>    ::= [a-z]


    Modes: beta, cps, quit

    * Type your lambda-term, and hit enter to reduce.
    * Hitting enter without typing anything reduces the previously
        reduced term in the current mode.
    * To change modes, type in a valid mode and hit enter. 
    * To quit, use CTRL+D or change to quit mode.

#### Examples


    (((\x.(\y.x)) y) a)
    ~beta~>
    ((\z.y) a)
    ~beta~>
    y

    --------------------

    ((\f.((f (\x.(\y.y))) (\x.(\y.x)))) (\x.(\y.x)))
    ~beta~>
    (((\x.(\y.x)) (\x.(\y.y))) (\x.(\y.x)))
    ~beta~>
    ((\y.(\x.(\y.y))) (\x.(\y.x)))
    ~beta~>
    (\x.(\y.y))

    --------------------

    (* 
        evaluate: plus 1 2
        
        Where numbers are encoded as Church numerals:
        0 := (\s.(\z.z))
        1 := (\s.(\z.(s z))) 
        2 := (\s.(\z.(s (s z))))  
        3 := (\s.(\z.(s (s (s z)))))
        ... etc 

        and plus is:
        plus := (\m.(\n.((m succ) n)))
        succ := (\m.(\s.(\z.(s ((m s) z)))))   
    *)


    (((\m.(\n.((m (\m.(\s.(\z.(s ((m s) z)))))) n))) (\s.(\z.(s z)))) (\s.(\z.(s (s z)))))
    ~beta~>
    ((\n.(((\s.(\z.(s z))) (\m.(\s.(\z.(s ((m s) z)))))) n)) (\s.(\z.(s (s z)))))
    ~beta~>
    (((\s.(\z.(s z))) (\m.(\s.(\z.(s ((m s) z)))))) (\s.(\z.(s (s z)))))
    ~beta~>
    ((\z.((\m.(\s.(\z.(s ((m s) z))))) z)) (\s.(\z.(s (s z)))))
    ~beta~>
    ((\m.(\s.(\z.(s ((m s) z))))) (\s.(\z.(s (s z)))))
    ~beta~>
    (\s.(\z.(s (((\s.(\z.(s (s z)))) s) z))))
    ~beta~>
    (\s.(\z.(s ((\z.(s (s z))) z))))
    ~beta~>
    (\s.(\z.(s (s (s z)))))

    --------------------

    (* cps = continuation passing transform, beta = beta reduction *)

    ((\x.y) z)
    ~cps~>
    (\k.((\k.(k (\x.(\k.(y k))))) (\m.((m (\k.(z k))) k))))
    ~cps~>beta
    ~beta~>
    (\k.((\m.((m (\k.(z k))) k)) (\x.(\k.(y k)))))
    ~beta~>
    (\k.(((\x.(\k.(y k))) (\k.(z k))) k))
    ~beta~>
    (\k.((\k.(y k)) k))
    ~beta~>
    (\k.(y k))

    --------------------

    (* Has no normal form *)


    ((\x.(x x)) (\y.(y y)))
    ~beta~>
    ((\y.(y y)) (\y.(y y)))
    ~beta~>
    ((\y.(y y)) (\y.(y y)))
    ~beta~>
    ((\y.(y y)) (\y.(y y)))

    --------------------

    (* CPS of first example *)

    (((\x.(\y.x)) y) a)
    ~cps~>
    (\k.((\k.((\k.(k (\x.(\k.(k (\y.(\k.(x k)))))))) (\m.((m (\k.(y k))) k)))) (\m.((m (\k.(a k))) k))))
    ~cps~>beta
    ~beta~>
    (\k.((\k.(k (\x.(\k.(k (\y.(\k.(x k)))))))) (\m.((m (\k.(y k))) (\m.((m (\k.(a k))) k))))))
    ~beta~>
    (\k.((\m.((m (\k.(y k))) (\m.((m (\k.(a k))) k)))) (\x.(\k.(k (\y.(\k.(x k))))))))
    ~beta~>
    (\k.(((\x.(\k.(k (\y.(\k.(x k)))))) (\k.(y k))) (\m.((m (\k.(a k))) k))))
    ~beta~>
    (\k.((\k.(k (\z.(\k.((\k.(y k)) k))))) (\m.((m (\k.(a k))) k))))
    ~beta~>
    (\k.((\m.((m (\k.(a k))) k)) (\z.(\k.((\k.(y k)) k)))))
    ~beta~>
    (\k.(((\z.(\k.((\k.(y k)) k))) (\k.(a k))) k))
    ~beta~>
    (\k.((\k.((\k.(y k)) k)) k))
    ~beta~>
    (\k.((\k.(y k)) k))
    ~beta~>
    (\k.(y k))

    
