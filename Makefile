include common_defs.mk



# Install constants

CORE_FILES = src/core/*$(CORE_LIB).*

MATH_FILES = src/math/*$(MATH_LIB).*

GRAPH_FILES = src/graphics/*$(GRAPHICS_LIB).*

UTILS_FILES = src/utils/*$(UTILS_LIB).*

DOC_FILES = src/core/$(CORE_LIB).mli src/graphics/$(GRAPHICS_LIB).mli src/math/$(MATH_LIB).mli src/utils/$(UTILS_LIB).mli


# Examples constants

EXAMPLE_MODULES = unix.cmxa bigarray.cmxa $(MATH_LIB).cmxa $(CORE_LIB).cmxa $(UTILS_LIB).cmxa $(GRAPHICS_LIB).cmxa

EXAMPLE_PKGS = ogaml.graphics,ogaml.utils

ifeq ($(OS_NAME), WIN)
    EXAMPLE_CMD = $(OCAMLOPT) -thread $(EXAMPLE_MODULES)
else
    EXAMPLE_CMD = $(OCAMLFIND) $(OCAMLOPT) -thread -linkpkg -package $(EXAMPLE_PKGS) -g
endif


# Tests constants

TEST_INCLUDES = -I src/core -I src/math -I src/graphics -I src/utils

TEST_MODULES = $(MATH_LIB).cmxa $(CORE_LIB).cmxa $(UTILS_LIB).cmxa $(GRAPHICS_LIB).cmxa

ifeq ($(OS_NAME), WIN)
    TEST_CMD = $(OCAMLOPT) -thread unix.cmxa bigarray.cmxa $(TEST_MODULES) $(TEST_INCLUDES)
else
    TEST_CMD = $(OCAMLFIND) $(OCAMLOPT) -thread -linkpkg $(TEST_INCLUDES) $(TEST_MODULES) -package unix,bigarray
endif

TEST_OUT = main.out 

ifeq ($(OS_NAME), WIN)
    LAUNCH_CMD = $(TEST_OUT)
else
    LAUNCH_CMD =./$(TEST_OUT)
endif



# Install constants

ifeq ($(OS_NAME), WIN)
    INSTALL_DIR = $(shell ocamlc -where)
    INSTALL_CMD = cp $(CORE_FILES) $(MATH_FILES) $(GRAPH_FILES) $(UTILS_FILES) $(INSTALL_DIR)
    UNINSTALL_CMD = 
else
    INSTALL_CMD = $(OCAMLFIND) install ogaml META $(CORE_FILES) $(MATH_FILES) $(GRAPH_FILES) $(UTILS_FILES)
    UNINSTALL_CMD = $(OCAMLFIND) remove "ogaml"
endif




# Compilation

default: depend math_lib utils_lib core_lib graphics_lib 

utils_lib:
	make -C src/utils/ default

math_lib:
	make -C src/math/ default

core_lib:
	make -C src/core/ default

graphics_lib: math_lib core_lib utils_lib
	make -C src/graphics/ default

examples:
	$(EXAMPLE_CMD) examples/cube.ml -o cube.out &&\
	$(EXAMPLE_CMD) examples/tut01.ml -o tut01.out &&\
	$(EXAMPLE_CMD) examples/tut02.ml -o tut02.out &&\
	$(EXAMPLE_CMD) examples/tut_tex.ml -o tut_tex.out &&\
	$(EXAMPLE_CMD) examples/tut_idx.ml -o tut_idx.out &&\
	$(EXAMPLE_CMD) examples/flat.ml -o flat.out &&\
	$(EXAMPLE_CMD) examples/vertexmaps.ml -o vertexmaps.out &&\
	$(EXAMPLE_CMD) examples/sprites.ml -o sprites.out &&\
	$(EXAMPLE_CMD) examples/ip.ml -o ip.out &&\
	$(EXAMPLE_CMD) examples/text.ml -o text.out &&\
	$(EXAMPLE_CMD) examples/noise.ml -o noise.out &&\
	$(EXAMPLE_CMD) examples/shoot.ml -o shoot.out
	
tests: math_lib core_lib graphics_lib utils_lib
	$(TEST_CMD) tests/programs.ml -o main.out && $(LAUNCH_CMD) &&\
	$(TEST_CMD) tests/vertexarrays.ml -o main.out && $(LAUNCH_CMD) &&\
	$(TEST_CMD) tests/graphs.ml -o main.out && $(LAUNCH_CMD) &&\
	$(TEST_CMD) tests/version.ml -o main.out && $(LAUNCH_CMD) &&\
	$(TEST_CMD) tests/capabilities.ml -o main.out && $(LAUNCH_CMD) &&\
	echo "Tests passed !"

version_test: math_lib core_lib graphics_lib utils_lib
	$(TEST_CMD) tests/version.ml -o main.out && $(LAUNCH_CMD)

doc:
	ocamlbuild -use-ocamlfind -use-menhir -cflags -rectypes -I src/doc -package unix,str mkdoc.native;\
	./mkdoc.native $(DOC_FILES)

install: math_lib core_lib graphics_lib utils_lib
	$(INSTALL_CMD)

reinstall:math_lib core_lib graphics_lib utils_lib uninstall install

uninstall:
	$(UNINSTALL_CMD)

clean:
	rm -f $(wildcard *.out) &\
	rm -rf doc &\
	ocamlbuild -clean &\
	make -C src/core clean &\
	make -C src/math clean &\
	make -C src/utils clean &\
	make -C src/graphics clean &\
	make -C tests/ clean &\
	make -C examples/ clean 

depend:
	make -C src/core depend &\
	make -C src/math depend &\
	make -C src/utils depend &\
	make -C src/graphics depend

.PHONY: install uninstall reinstall examples doc
