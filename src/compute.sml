
datatype term = Var of string | App of term * term | Lambda of string * term;

fun isMember str strList = List.exists (fn z => String.compare(str, z) = EQUAL) strList;

fun flatten (Lambda(x, t)) = "\\" ^ x ^ ".(" ^ flatten(t) ^ ")"
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

