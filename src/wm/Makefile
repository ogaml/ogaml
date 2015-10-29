include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I $(OS_WIN_STUBS_DIR)

MLSOURCES = window.ml

MLINTERFACES = button.mli keycode.mli event.mli

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

MLLIB = ogamlWindow

PACKNAME = OgamlWindow



# Compilation

default: .depend compile_window_nat compile_window_byte

compile_os_lib:
	cd $(OS_WIN_STUBS_DIR) && make

compile_window_nat: .depend compile_os_lib $(MLCMIS) $(MLNATOBJS)
	$(OCAMLOPT) -pack -o $(MLLIB).cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLOPT) -a -o $(MLLIB).cmxa $(INCLUDE_DIRS) $(MLLIB).cmx -cclib -l$(strip $(OS_WIN_STUBS))

compile_window_byte: .depend compile_os_lib $(MLCMIS) $(MLOBJS)
	$(OCAMLC) -pack -o $(MLLIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLC) -a -o $(MLLIB).cma $(INCLUDE_DIRS) $(MLLIB).cmo -cclib -l$(strip $(OS_WIN_STUBS))

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c -for-pack $(PACKNAME) -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml
	$(OCAMLC) -c -for-pack $(PACKNAME) -o $@ $(INCLUDE_DIRS) $<

%.ml:%.mlpp %.cmi
	$(PPCOMMAND) -o $@ $<



# Cleaning

clean:
	rm -rf $(EXTENSIONS) ogamlWindow.ml;
	cd $(OS_WIN_STUBS_DIR) && make clean


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend
