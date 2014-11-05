

reduck: src/code.sml
	mlton -output reduck src/code.sml

clean:
	rm -f reduck
