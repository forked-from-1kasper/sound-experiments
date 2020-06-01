build: native

native:
	ocamlbuild -use-menhir synth.native

clean:
	ocamlbuild -clean
