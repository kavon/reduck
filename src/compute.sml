
datatype term = Var of string | App of term * term | Lambda of string * term;

fun flatten (Lambda(x, t)) = "L" ^ x ^ ".(" ^ flatten(t) ^ ")"
  | flatten (App(a, b)) = "(" ^ flatten(a) ^ " " ^ flatten(b) ^ ")"
  | flatten (Var(x)) = x;

fun freeVariables (Var(x), bindings) = 
	if (List.exists (fn z => (String.compare(z, x) = EQUAL)) bindings) then
		nil
	else 
		[x]
  | freeVariables (App(left, right), bindings) = freeVariables(left, bindings) @ freeVariables(right, bindings) (* better with set union *)
  | freeVariables (Lambda(x, t), bindings) = freeVariables(t, x::bindings);



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
  						val newV = "j"; (* TODO: pickNew(freeVariables(term, bindings) @ freeInRepl @ bindings); *)
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

