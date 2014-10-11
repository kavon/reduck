
(* parse, betaReduce, flatten, display loop goes here *)

use "compute.sml";
use "parse.sml";

(* TEMP *)

val infy = Lambda("x", App(Var("x"), Var("x")));

(* END TEMP *)

fun topLoop(old) = 
let
	val _ = print "~>"
	val input = TextIO.inputLine(TextIO.stdIn);
	val enteredSomething = Option.isSome(input);
	val eval = if enteredSomething then Option.valOf(input) else old; (* TODO: trim whitespace and remove newline. 
																				this "enteredSomething" is also wrong. *)
in
	if not enteredSomething then 
		OS.Process.exit(OS.Process.success) 
	else
		let
			val parsed = parse(Option.valOf(input));
			val reduced = betaReduce(parsed, nil);
			val output = flatten(reduced);
			val _ = if enteredSomething then 
						print ("\n\n--------------------\n\n" ^ eval ^ "~ beta ~>\n" ^ output ^ "\n")
					else
						print (output ^ "\n")
		in
			topLoop(output)
		end
end;

print "\n\nJust start typing your lambda-term, and hit enter to reduce. \n Hitting enter without typing anything continues reduction.\n\n";
topLoop("quit");




