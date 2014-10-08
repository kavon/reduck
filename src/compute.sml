
datatype term = var of string | app of (term * term) | lambda of (string * term);

fun beta-reduce app(lambda(x, t), b) = replace(x, b, t)  (* return t[x:=b] *)
              | app(left, right) = let  (* do left first, if no replacement occured, do right *)
					val leftR = beta-reduce(left);
                                        val rightR = beta-reduce(right);
                                   in
                                   
                                    end;
              
               | lambda(_, t) = beta-reduce(t); 
	       | x = x; (* bottomed out *)


