
(* COMPUTATION CODE START *)

datatype term = Var of string | App of term * term | Lambda of string * term;

fun isMember str strList = List.exists (fn z => String.compare(str, z) = EQUAL) strList;

fun flatten (Lambda(x, t)) = "(\\" ^ x ^ "." ^ flatten(t) ^ ")"
  | flatten (App(a, b)) = "(" ^ flatten(a) ^ " " ^ flatten(b) ^ ")"
  | flatten (Var(x)) = x;

fun freeVariables (Var(x), bindings) = if isMember x bindings then nil else [x]
  | freeVariables (App(left, right), bindings) = freeVariables(left, bindings) @ freeVariables(right, bindings) (* would be better with set union *)
  | freeVariables (Lambda(x, t), bindings) = freeVariables(t, x::bindings);

fun genSymbol (old, reserved) = if isMember old reserved then
					if length(reserved) < 26 andalso String.size(old) = 1 then (* we'll try the next letter in the alphabet *)
						let 
							val succCh = Char.succ(hd (String.explode(old)))
						    	val newCh = if succCh <= #"z" then succCh else #"a"
						in
							genSymbol(Char.toString(newCh), reserved)
						end
					else
						genSymbol(old ^ "'", reserved)
				else
					old;

(* return term[x:=arg] w/ respect to the outer bindings in effect on term (perform alpha-conversion as needed) *)
fun replace (Var(v), x, repl, bindings) = if (String.compare(v, x) = EQUAL) then repl else Var(v)
  | replace (App(left, right), x, repl, bindings) = App(replace(left, x, repl, bindings), replace(right, x, repl, bindings))
  | replace (Lambda(v, term), x, repl, bindings) =  
  		if (String.compare(v, x) = EQUAL) then
  			Lambda(v, term) 
  		else
  			let 
  				val freeInRepl = freeVariables(repl, bindings)
  			in
  				if (List.exists (fn z => String.compare(v, z) = EQUAL) freeInRepl) then
  					let 
  						val newV = genSymbol(v, freeVariables(term, bindings) @ freeInRepl @ bindings);
  						val alphaConverted = Lambda(newV, replace(term, v, Var(newV), bindings));
  					in
						replace(alphaConverted, x, repl, bindings)
					end
  				else
  					Lambda(v, replace(term, x, repl, v::bindings))
			end;



fun betaReduce (App(Lambda(x, term), arg), bindings) = replace(term, x, arg, bindings)
  | betaReduce (App(left, right), bindings) = 
  		let
  			val leftReduced = betaReduce(left, bindings);
  		in
			if (String.compare(flatten(leftReduced), flatten left) = EQUAL) then
				App(left, betaReduce(right, bindings)) (* at the top level, check if the term didn't change if it's in beta-nf *)
			else
				App(leftReduced, right)
		end         
  | betaReduce  (Lambda(x, t), bindings) = Lambda(x, betaReduce(t, x::bindings))
  | betaReduce  (x, _) = x; (* bottomed out *)


fun cps (Var(x), bindings) = 
        let
            val k = genSymbol("k", [x]) (* pick a fresh variable, aka, make sure x isn't k *)
        in
            Lambda(k, App(Var(x), Var(k)))
        end

   | cps (Lambda(x, term), bindings) = 
        let
            val k = genSymbol("k", freeVariables(term, bindings))
        in
            Lambda(k, App(Var(k), Lambda(x, cps(term, x::k::bindings))))
        end
   | cps (App(x, y), bindings) =
        let
            val fv_x = freeVariables(x, bindings)
            val fv_y = freeVariables(y, bindings)
            val k = genSymbol("k", fv_x @ fv_y)
            val m = genSymbol("m", fv_y)
            val cps_x = cps(x, k::bindings)
            val cps_y = cps(y, k::m::bindings)
        in
            Lambda(k, App(cps_x, Lambda(m, App(App(Var(m), cps_y), Var(k)))))
        end

(* COMPUTATION CODE END *)



(* PARSING CODE START *)

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


(* PARSING CODE END *)




(* INPUT AND OUTPUT CODE START *)

fun quitProgram _ = let
                        val _ = print "\n"; (* printing a newline looks nice before quitting *)
                    in
                        OS.Process.exit(OS.Process.success)
                    end

fun topLoop(old, mode) = 
let
	val _ = print ("~" ^ mode ^ "~>")
	val maybeInput = TextIO.inputLine(TextIO.stdIn);
	val input = String.implode(trim (String.explode(if Option.isSome(maybeInput) then Option.valOf(maybeInput) else quitProgram()))); 


    (* If they just input a mode, switch modes and reissue "old" *)
    val _ = (case input of "beta" => topLoop(old, "beta")
                        | "cps" => topLoop(old, "cps")
                        | "quit" => quitProgram()
                        | _ => ())

    val isUsingOld = (input = "")
    val eval = if isUsingOld then (if old = "quit" then quitProgram() else old) else input

	val parsed = parse(eval)
	val reduced = (case mode of "beta" => betaReduce(parsed, nil)
                              | "cps" => cps(parsed, nil)
                              | _ => raise Fail "have no reduction mode set!")
	val output = flatten(reduced)

	val _ = if isUsingOld then 
						print (output ^ "\n")
					else
						print ("\n\n--------------------\n\n" ^ eval ^ "\n~ " ^ mode ^ " ~>\n" ^ output ^ "\n")
in
	topLoop(output, mode)
end;

(* INPUT AND OUTPUT CODE END *)



(* "Main" *)
print "Syntax:\n\n";
print "<lambda-term> ::= <variable>\n";
print "              ::= (\\<variable>.<lambda-term>)       abstraction\n";
print "              ::= (<lambda-term> <lambda-term>)     application\n";
print "\n<variable>    ::= [a-zA-Z]\n";
print "\nModes: beta, cps, quit";
print "\n\nType your lambda-term, and hit enter to reduce.";
print "\n Hitting enter without typing anything reduces the previously\n reduced term in the current mode.";
print "\n To change modes, type in a valid mode and hit enter. \n To quit, use CTRL+D or change to quit mode.\n\n";
val _ = topLoop("quit", "beta");

(* "Main" *)




