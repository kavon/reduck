
(* parse, betaReduce, flatten, display loop goes here *)

use "compute.sml";
use "parse.sml";

(* TEMP *)

val infy = Lambda("x", App(Var("x"), Var("x")));

(* END TEMP *)

fun topLoop(old) = 
let
	val _ = print "~>"
	val maybeInput = TextIO.inputLine(TextIO.stdIn);

	val input = if Option.isSome(maybeInput) then Option.valOf(maybeInput) else OS.Process.exit(OS.Process.success);
	val isUsingOld = (input = "\n")
	val eval = if isUsingOld then (if old = "quit" then OS.Process.exit(OS.Process.success) else old) else input

	val parsed = parse(eval);
	val reduced = betaReduce(parsed, nil);
	val output = flatten(reduced);

	val _ = if isUsingOld then 
						print (output ^ "\n")
					else
						print ("\n\n--------------------\n\n" ^ eval ^ "~ beta ~>\n" ^ output ^ "\n")
in
	topLoop(output)
end;

print "\n\nJust start typing your lambda-term, and hit enter to reduce. \n Hitting enter without typing anything continues reduction.\n\n";
topLoop("quit");




