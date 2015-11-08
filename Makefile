include common_defs.mk


# Window constants

INCLUDES = -I src/core -I src/math -I src/graphics

MODULES = ogamlMath.cmxa ogamlCore.cmxa ogamlGraphics.cmxa

PACKAGES = -package bigarray,unix,str


# Install constants

CORE_FILES = src/core/*.a src/core/*.cmi src/core/*.cma src/core/*.cmxa\
	     src/core/*.so 

MATH_FILES = src/math/*.a src/math/*.cmi src/math/*.cma src/math/*.cmxa

GRAPH_FILES = src/graphics/*.a src/graphics/*.cmi src/graphics/*.cma\
	      src/graphics/*.cmxa src/graphics/*.so 


# Compilation

default: math_lib core_lib graphics_lib

math_lib:
	cd src/math/ && make

core_lib: 
	cd src/core/ && make

graphics_lib: core_lib math_lib
	cd src/graphics/ && make

example: math_lib core_lib graphics_lib
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) examples/cube.ml -o main.out

tests: math_lib core_lib graphics_lib
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/programs.ml -o main.out && ./main.out &&\
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/vertexarrays.ml -o main.out && ./main.out &&\
	echo "Tests passed !"

install: math_lib core_lib graphics_lib
	$(OCAMLFIND) install ogaml META $(CORE_FILES) $(MATH_FILES) $(GRAPH_FILES)

uninstall:
	$(OCAMLFIND) remove "ogaml"

clean:
	rm -rf *.out;
	cd src/core/ && make clean;
	cd src/math/ && make clean;
	cd src/graphics/ && make clean;
	cd tests/ && make clean;
	cd examples/ && make clean

