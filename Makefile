include common_defs.mk


# Window constants

WINDOW_INCLUDES = -I src/wm -I src/wm/$(strip $(OS_WIN_STUBS_DIR)) -I src/math

WINDOW_CMXA = $(OS_WIN_STUBS).cmxa ogamlWindow.cmxa

MATH_CMXA = ogamlMath.cmxa

PACKAGES = -package tgls.tgl4,bigarray,unix

WINDOW_TEST = src/test/test_window.ml

STUBS_TEST = src/test/$(strip $(OS_WIN_STUBS_TEST)).ml


# Constants

OUTPUT = main.out


# Compilation

default: window_test

window_lib:
	cd src/wm/ && make

math_lib:
	cd src/math/ && make

gl_lib:
	cd src/gl/ && make

window_test: window_lib math_lib
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -o $(OUTPUT) $(PACKAGES) $(WINDOW_INCLUDES)\
	  $(WINDOW_CMXA) $(MATH_CMXA) $(WINDOW_TEST)

stubs_test: stubs_lib math_lib
	$(OCAMLFIND) $(OCAMLOPT) -linkpkg -o $(OUTPUT) $(PACKAGES) $(WINDOW_INCLUDES)\
	  $(OS_WIN_STUBS).cmxa $(MATH_CMXA) $(STUBS_TEST)

stubs_lib:
	cd src/wm/$(strip $(OS_WIN_STUBS_DIR)) && make

clean:
	rm -rf *.out;
	cd src/wm/ && make clean;
	cd src/test/ && make clean;
	cd src/math/ && make clean;
	cd src/gl/ && make clean
