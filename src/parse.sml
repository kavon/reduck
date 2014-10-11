
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
	


fun descend (LAMB::STR(x)::DOT::tokens) = 
	let
		val ret = descend(tokens);
		val term = #1 ret; (* the term we're abstracting over *)
		val leftover = #2 ret; (* tokens leftover *)
		val absTerm = Option.getOpt(term, raise Fail("NoLambdaBody"))
	in
		case leftover of
		  WS::leftover => let
		  	val ret = descend(leftover);
		  	val term = #1 ret;
		  	val leftover = #2 ret;
		  in
		  	(SOME(App(Lambda(x, absTerm), Option.getOpt(term, raise Fail("NoArg_1")))), leftover)
		  end
		| wat => (SOME(Lambda(x, absTerm)), wat)
	end

  | descend (STR(x)::tokens) = 
	let
		val _ = print "-- TOP DESCEND\n"
		val ret = descend(tokens);
		val term = #1 ret;
		val leftover = #2 ret; (* if WS is on top, this is an app. *)
		val _ = print "-- TOP HAS LEFT\n"
		val _ = printTokens(leftover);
	in
		case leftover of
			  WS::leftover => let
			  		val _ = print "-- BOTTOM DESCEND\n"
					val ret = descend(leftover);
					val _ = print "-- BOTTOM HAS LEFT\n"
					val _ = printTokens(#2 ret);
					val _ = if Option.isSome(#1 ret) then (print "and got Some") else (print "and got None!");
				in
					(SOME(App(Var(x), Option.getOpt((#1 ret), raise Fail("NoArg_2")))), (#2 ret))
				end  
			| RPAREN::leftover => let val _ = print "-- returning a var before an rparen\n" in (SOME(Var(x)), RPAREN::leftover) end
			| leftover => (SOME(Var(x)), leftover)
	end

  | descend (WS::tokens) = (NONE, WS::tokens)
  | descend (RPAREN::tokens) = (NONE, RPAREN::tokens)
  | descend (LPAREN::tokens) = let
					val ret = descend(tokens);
					val term = #1 ret;
					val leftover = #2 ret;
				in
					if (hd leftover) <> RPAREN then
						raise Fail("UnbalancedParens")
					else
						(term, tl leftover)
				end

  | descend (_) = raise Fail("InvalidTokenSequence");


fun parse s =
	let
		val cs = trim(String.explode(s));
		val tokens = rev(tokenize(cs, nil));
		(*val _ = printTokens(tokens);*)
		val parseResult = descend(tokens);
	in
		Option.getOpt((#1 parseResult), raise Fail("OMG"))
	end;


