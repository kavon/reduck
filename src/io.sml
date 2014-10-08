
(* temp *)
datatype term = Var of string | App of term * term | Lambda of string * term;

(* ideally, we want to use λ, but we gotta also support \ because some consoles are lame *)

fun stringify (Lambda(x, t)) = (Char.toString #"\\") (* ??? *) ^ x ^ ".(" ^ stringify(t) ^ ")"
  | stringify (App(a, b)) = "(" ^ stringify(a) ^ " " ^ stringify(b) ^ ")"
  | stringify (Var(x)) = x;
