DIRS=src,src/wm

default:
	ocamlbuild -use-ocamlfind -package unix -Is $(DIRS) main.native
