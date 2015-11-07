include common_defs.mk


# Window constants

INCLUDES = -I src/wm -I src/wm/$(strip $(OS_WIN_STUBS_DIR)) -I src/math -I src/gl

MODULES = $(OS_WIN_STUBS).cmxa ogamlMath.cmxa ogamlGL.cmxa ogamlWindow.cmxa

GL_FILES = src/gl/*.a src/gl/*.cmx src/gl/*.cmi src/gl/*.mli src/gl/*.cma src/gl/*.cmxa src/gl/*.cmo

MATH_FILES = src/math/*.a src/math/*.cmx src/math/*.cmi src/math/*.mli src/math/*.cma src/math/*.cmxa src/math/*.cmo

WINDOW_FILES = src/wm/*.a src/wm/*.cmx src/wm/*.cmi src/wm/*.mli src/wm/*.cma src/wm/*.cmxa src/wm/*.cmo

WMLIB_FILES = src/wm/$(strip $(OS_WIN_STUBS_DIR))*.a   src/wm/$(strip $(OS_WIN_STUBS_DIR))*.cmx\
	      src/wm/$(strip $(OS_WIN_STUBS_DIR))*.cmi src/wm/$(strip $(OS_WIN_STUBS_DIR))*.mli\
	      src/wm/$(strip $(OS_WIN_STUBS_DIR))*.cmxa #src/wm/$(strip $(OS_WIN_STUBS_DIR))*.so\
	      #src/wm/$(strip $(OS_WIN_STUBS_DIR))*.cmo

PACKAGES = -package bigarray,unix


# Constants

OUTPUT = main.out


# Compilation

default: stubs_lib math_lib gl_lib window_lib

window_lib: gl_lib
	cd src/wm/ && make

math_lib:
	cd src/math/ && make

gl_lib: math_lib
	cd src/gl/ && make

stubs_lib:
	cd src/wm/$(strip $(OS_WIN_STUBS_DIR)) && make

example: stubs_lib math_lib gl_lib window_lib
	$(OCAMLFIND) ocamlopt -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) examples/cube.ml -o main.out

tests: stubs_lib math_lib gl_lib window_lib
	$(OCAMLFIND) ocamlopt -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/programs.ml -o main.out && ./main.out &&\
	$(OCAMLFIND) ocamlopt -linkpkg $(INCLUDES) $(MODULES) $(PACKAGES) tests/vertexarrays.ml -o main.out && ./main.out &&\
	echo "Tests passed !"

install:
	$(OCAMLFIND) install ogaml META $(GL_FILES) $(MATH_FILES) $(WINDOW_FILES) $(WMLIB_FILES)

uninstall:
	$(OCAMLFIND) remove "ogaml"

clean:
	rm -rf *.out;
	cd src/wm/ && make clean;
	cd src/test/ && make clean;
	cd src/math/ && make clean;
	cd src/gl/ && make clean;
	cd tests/ && make clean

