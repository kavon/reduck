
(* returns the next 0 or more chars c s.t. p(c) is true. *)
fun kleeneStar p nil = nil
  | kleeneStar p x::xs = if p(x) then x::kleeneStar(p, xs) else nil;

fun trim s = rev(List.drop(length(kleeneStar Char.isSpace s), (rev(List.drop(length(kleeneStar Char.isSpace s), s)))));

datatype token = LPAREN | RPAREN | LAMB | DOT | WS | STR of string;

fun tokenize nil tokens = tokens
  | tokenize c::cs tokens =
	case c of
	| #"."  => tokenize(cs, DOT::tokens)
	| #"\\" => tokenize(cs, LAMB::tokens)
	| #"("  => tokenize(cs, LPAREN::tokens)
	| #")"  => tokenize(cs, RPAREN::tokens)
	| c	=> let
			val whiteSpace = length(kleeneStar Char.isSpace c::cs);
		   in
			if whiteSpace > 0 then 
				tokenize(List.drop(c::cs, whiteSpace), WS::tokens) 
			else
				let
					val alphaNums = kleeneStar Char.isAlphaNum c::cs
				in
					if length(alphaNums) = 0 then 
						raise SyntaxError 
					else
						tokenize(List.drop(c::cs, length(alphaNums)), STR(String.implode(alphaNums))::tokens)
				end
		   end;		
	


fun descend LAMB::STR(x)::DOT::tokens = 
	let
		val ret = descend(tokens);
		val term = #1 ret; (* the term we're abstracting over *)
		val leftover = #2 ret; (* tokens leftover *)
		val absTerm = Option.getOpt(term, raise NoLambdaBody)
	in
		case leftover of
		| WS::leftover => (SOME(App(Lambda(x, absTerm), descend(leftover))), leftover)
		| wat => (SOME(Lambda(x, absTerm)), wat)
	end;

  | descend STR(x)::tokens = 
	let
		val ret = descend(tokens);
		val term = #1 ret;
		val leftover = #1 ret;
	in
		case leftover of
		| WS::leftover => let
					val ret = descend(leftover);
					val term = #1 ret;
					val leftover #2 ret;
				in
					(SOME(App(Var(x), Option.getOpt(term, raise NoArg))), leftover)
				end  
		| wat => (SOME(Var(x)), wat)
	end;

  | descend WS::tokens = (NONE, WS::tokens)
  | descend RPAREN::tokens = (NONE, RPAREN::tokens)
  | descend LPAREN::tokens = let
					val ret = descend(tokens);
					val term = #1 ret;
					val leftover = #2 ret;
				in
					if (hd leftover) != RPAREN then
						raise UnbalancedParens
					else
						(term, tl leftover)
				end;


fun parse s =
	let
		val cs = trim(String.explode s);
		val tokens = rev tokenize(cs, nil);
	in
		Option.getOpt((#1 descend(tokens)), raise OMG)
	end;


