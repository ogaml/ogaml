include common_defs.mk


# Window constants

WINDOW_INCLUDES = -I src/wm -I src/wm/$(strip $(OS_WIN_STUBS_DIR))

WINDOW_CMXA = $(OS_WIN_STUBS).cmxa ogamlWindow.cmxa unix.cmxa

WINDOW_TEST = src/test/test_window.ml

STUBS_TEST = src/test/$(strip $(OS_WIN_STUBS_TEST)).ml


# Constants

OUTPUT = main.out


# Compilation

default: window_test

window_lib:
	cd src/wm/ && make

window_test: window_lib
	$(OCAMLOPT) -o $(OUTPUT) $(WINDOW_INCLUDES) $(WINDOW_CMXA) $(WINDOW_TEST)

stubs_test: stubs_lib
	$(OCAMLOPT) -o $(OUTPUT) $(WINDOW_INCLUDES) $(OS_WIN_STUBS).cmxa $(STUBS_TEST)

stubs_lib:
	cd src/wm/$(strip $(OS_WIN_STUBS_DIR)) && make

clean:
	rm -rf *.out;
	cd src/wm/ && make clean;
	cd src/test/ && make clean
