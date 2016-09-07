include common_defs.mk


# Window constants

INCLUDES = -I src/core -I src/math -I src/graphics -I src/utils

MODULES = $(MATH_LIB).cmxa $(CORE_LIB).cmxa $(UTILS_LIB).cmxa $(GRAPHICS_LIB).cmxa

PACKAGES = -package bigarray,unix,str


# Install constants

CORE_FILES = src/core/*$(CORE_LIB).*

MATH_FILES = src/math/*$(MATH_LIB).*

GRAPH_FILES = src/graphics/*$(GRAPHICS_LIB).*

UTILS_FILES = src/utils/*$(UTILS_LIB).*

DOC_FILES = src/graphics/$(GRAPHICS_LIB).mli src/core/$(CORE_LIB).mli src/math/$(MATH_LIB).mli src/utils/$(UTILS_LIB).mli


# Examples constants

EXAMPLE_PKG = ogaml.graphics,ogaml.utils


# Compilation

default: math_lib core_lib utils_lib graphics_lib 

utils_lib:
	cd src/utils/ && make

math_lib:
	cd src/math/ && make

core_lib:
	cd src/core/ && make

graphics_lib: core_lib math_lib utils_lib
	cd src/graphics/ && make

examples:
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/cube.ml -o cube.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/tut01.ml -o tut01.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/tut02.ml -o tut02.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/tut_tex.ml -o tut_tex.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/tut_idx.ml -o tut_idx.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/flat.ml -o flat.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/vertexmaps.ml -o vertexmaps.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/sprites.ml -o sprites.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/ip.ml -o ip.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/text.ml -o text.out;
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -package $(EXAMPLE_PKG) examples/noise.ml -o noise.out

tests: math_lib core_lib graphics_lib utils_lib
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/programs.ml -o main.out && ./main.out &&\
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/vertexarrays.ml -o main.out && ./main.out &&\
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/graphs.ml -o main.out && ./main.out &&\
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/version.ml -o main.out && ./main.out &&\
	echo "Tests passed !"

doc:
	ocamlbuild -use-ocamlfind -use-menhir -cflags -rectypes -I src/doc -package unix,str mkdoc.native;\
	./mkdoc.native $(DOC_FILES)

install: math_lib core_lib graphics_lib utils_lib
	$(OCAMLFIND) install ogaml META $(CORE_FILES) $(MATH_FILES) $(GRAPH_FILES) $(UTILS_FILES)

reinstall:math_lib core_lib graphics_lib utils_lib uninstall install

uninstall:
	$(OCAMLFIND) remove "ogaml"

clean:
	rm -rf *.out;
	rm -rf html;
	ocamlbuild -clean;
	cd src/core/ && make clean;
	cd src/math/ && make clean;
	cd src/utils/ && make clean;
	cd src/graphics/ && make clean;
	cd tests/ && make clean;
	cd examples/ && make clean

.PHONY: install uninstall reinstall examples doc
