include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I $(OS_WIN_STUBS_DIR)

MLSOURCES = ogamlWindow.ml

MLOBJS = $(MLSOURCES:.ml=.cmo)

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLLIB = ogamlWindow.cmxa ogamlWindow.cma


# Compilation

default: depend $(MLLIB)

compile_xlib:
	cd $(OS_WIN_STUBS_DIR) && make

%.cma:%.cmo compile_xlib
	$(OCAMLC) -a -o $@ $(INCLUDE_DIRS) $< -dllib -l$(strip $(OS_WIN_STUBS))

%.cmxa:%.cmx compile_xlib
	$(OCAMLOPT) -a -o $@ $(INCLUDE_DIRS) $< -cclib -l$(strip $(OS_WIN_STUBS))

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c -o $@ $(INCLUDE_DIRS) $< -cclib -l$(strip $(OS_WIN_STUBS))

%.cmo:%.ml
	$(OCAMLC) -c -o $@ $(INCLUDE_DIRS) $< -dllib -l$(strip $(OS_WIN_STUBS))

%.ml:%.mlpp %.cmi
	$(PPCOMMAND) -o $@ $<



# Cleaning

clean:
	rm -rf $(EXTENSIONS) ogamlWindow.ml;
	cd $(OS_WIN_STUBS_DIR) && make clean


# Dependencies

depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend


