
(* parse, betaReduce, flatten, display loop goes here *)

use "compute.sml";

(* TEMP *)

val infy = Lambda("x", App(Var("x"), Var("x")));

(* END TEMP *)

fun topLoop(old) = 
let
	val input = TextIO.inputLine(TextIO.stdIn);
	val enteredSomething = Option.isSome(input);
	val eval = if enteredSomething then Option.valOf(input) else old;
in
	if (String.compare(eval, "quit") = EQUAL) then 
		OS.Process.exit(OS.Process.success) 
	else
		let
			val parsed = App(infy, infy); (* parse(input); *)
			val reduced = betaReduce(parsed, nil);
			val output = flatten(reduced);
			val _ = print ("beta ->\n" ^ output)
		in
			topLoop(output)
		end
end;

print "\n\nJust start typing your lambda-term, and hit enter to reduce. \n Hitting enter without typing anything continues reduction.\n\n";
topLoop("quit");




