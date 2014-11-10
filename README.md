reduck
======

A tool that finds the [beta normal form](http://en.wikipedia.org/wiki/Beta_normal_form) (β-nf) of a lambda term step-by-step. It's basically an interpreter for an abstract functional programming language that shows each computational step during evaluation. The evaluation strategy is to find the left-most application of a lambda abstraction to some term and apply the β-rule. I don't have a proof (at the moment) that for any λ-term, this will always find a β-nf if it exists... but it probably will.

#### Building

You'll need either [MLton](http://mlton.org) or [SML/NJ](http://www.smlnj.org) installed. Using MLton, you can just run `make` in the top level directory to build an independent binary, and if you're using SML/NJ, run `sml src/code.sml` from that same directory.

#### Syntax

    <lambda-term> ::= <variable>
                  ::= (\<variable>.<lambda-term>)       λ-abstraction
                  ::= (<lambda-term> <lambda-term>)     application

    <variable>    ::= [a-zA-Z]

#### Examples


    (((\x.(\y.x)) y) a)
    ~ beta ~>
    ((\z.y) a)
    ~>
    y

    --------------------

    ((\f.((f (\x.(\y.y))) (\x.(\y.x)))) (\x.(\y.x)))
    ~ beta ~>
    (((\x.(\y.x)) (\x.(\y.y))) (\x.(\y.x)))
    ~>
    ((\y.(\x.(\y.y))) (\x.(\y.x)))
    ~>
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
    ~ beta ~>
    ((\n.(((\s.(\z.(s z))) (\m.(\s.(\z.(s ((m s) z)))))) n)) (\s.(\z.(s (s z)))))
    ~>
    (((\s.(\z.(s z))) (\m.(\s.(\z.(s ((m s) z)))))) (\s.(\z.(s (s z)))))
    ~>
    ((\z.((\m.(\s.(\z.(s ((m s) z))))) z)) (\s.(\z.(s (s z)))))
    ~>
    ((\m.(\s.(\z.(s ((m s) z))))) (\s.(\z.(s (s z)))))
    ~>
    (\s.(\z.(s (((\s.(\z.(s (s z)))) s) z))))
    ~>
    (\s.(\z.(s ((\z.(s (s z))) z))))
    ~>
    (\s.(\z.(s (s (s z)))))

    --------------------

    ((\x.y) z)
    ~ cps ~>
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
    ~ beta ~>
    ((\y.(y y)) (\y.(y y)))
    ~>
    ((\y.(y y)) (\y.(y y)))
    ~>
    ((\y.(y y)) (\y.(y y)))

    
