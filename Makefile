include common_defs.mk


# Window constants

INCLUDES = -I src/core -I src/math -I src/graphics

MODULES = ogamlCore.cmxa ogamlGraphics.cmxa ogamlMath.cmxa

PACKAGES = -package bigarray,unix


# Compilation

default: math_lib core_lib graphics_lib

math_lib:
	cd src/math/ && make

core_lib: 
	cd src/core/ && make

graphics_lib: core_lib math_lib
	cd src/graphics/ && make

example: math_lib core_lib
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) examples/cube.ml -o main.out

tests: math_lib core_lib 
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/programs.ml -o main.out && ./main.out &&\
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/vertexarrays.ml -o main.out && ./main.out &&\
	echo "Tests passed !"

clean:
	rm -rf *.out;
	cd src/core/ && make clean;
	cd src/math/ && make clean;
	cd src/graphics/ && make clean;
	cd tests/ && make clean

