
(* returns the next 0 or more chars c s.t. p(c) is true. *)
fun kleeneStar (_, nil) = nil
  | kleeneStar (p, x::xs) = if p(x) then x::kleeneStar(p, xs) else nil;

fun trimFront s = List.drop(s, length(kleeneStar (Char.isSpace, s)));

fun trim s = rev(trimFront(rev(trimFront(s))));

datatype token = LPAREN | RPAREN | LAMB | DOT | WS | STR of string;

fun printTokens (x::xs) = let
	val _ = (case x of
				LPAREN => print "LPAREN\n"
				| RPAREN => print "RPAREN\n"
				| LAMB => print "LAMB\n"
				| DOT => print "DOT\n"
				| WS => print "WS\n"
				| STR(x) => print ("STR(" ^ x ^ ")\n"));
	in
		printTokens(xs)
	end

   | printTokens(nil) = ();


fun tokenize (nil, tokens) = tokens
  | tokenize (c::cs, tokens) =
	case c of
	  #"."  => tokenize(cs, DOT::tokens)
	| #"\\" => tokenize(cs, LAMB::tokens)
	| #"("  => tokenize(cs, LPAREN::tokens)
	| #")"  => tokenize(cs, RPAREN::tokens)
	| c	=> let
			val whiteSpace = length(kleeneStar (Char.isSpace, c::cs));
		   in
			if whiteSpace > 0 then 
				tokenize(List.drop(c::cs, whiteSpace), WS::tokens) 
			else
				let
					val alphaNums = kleeneStar (Char.isAlphaNum, c::cs);
				in
					if length(alphaNums) = 0 then 
						raise Fail("SyntaxError")
					else
						tokenize(List.drop(c::cs, length(alphaNums)), STR(String.implode(alphaNums))::tokens)
				end
		   end;		
	


    (* abstraction *)
fun descend (LPAREN::LAMB::STR(x)::DOT::tokens) = 
	let
		val (term, leftover) = descend(tokens);
		val theRest = if List.hd(leftover) = RPAREN then List.tl(leftover) else raise Fail "NoRparenLambda";
	in
		(Lambda(x, term), theRest)
	end

    (* application *)
  | descend(LPAREN::tokens) =
  	let
  		val (lTerm, lRemain) = descend(tokens);
  		
  		val rightHalf = if List.hd(lRemain) = WS then List.tl(lRemain) else raise Fail "NoWSApp";
  		
  		val (rTerm, rRemain) = descend(rightHalf)

  		val theRest = if List.hd(rRemain) = RPAREN then List.tl(rRemain) else raise Fail "NoRParenApp";
  	in
  		(App(lTerm, rTerm), theRest)
  	end

  	(* variable *)
  | descend (STR(x)::tokens) = (Var(x), tokens)

  | descend (_) = raise Fail "wat"


fun parse s =
	let
		val cs = trim(String.explode(s));
		val tokens = rev(tokenize(cs, nil));
		val (term, leftoverTokens) = descend(tokens);
	in
		term
	end;


