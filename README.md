reduck
======

A little tool that finds the beta normal form (β-nf) of a lambda term step-by-step. The evaluation strategy is to find the left-most application of a lambda abstraction to some term and apply the β-rule. I don't have a proof (at the moment) that for any λ-term, this will always find a β-nf if it exists.

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
        plus 1 2, where: 
        
        1 := (\s.(\z.(s z))) 
        2 := (\s.(\z.(s (s z))))  
        succ := (\m.(\s.(\z.(s ((m s) z)))))   
        plus := (\m.(\n.((m succ) n)))
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

    (* Has no normal form *)

    ((\x.(x x)) (\y.(y y)))
    ~ beta ~>
    ((\y.(y y)) (\y.(y y)))
    ~>
    ((\y.(y y)) (\y.(y y)))
    ~>
    ((\y.(y y)) (\y.(y y)))

    
