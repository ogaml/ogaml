include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I $(OS_WIN_STUBS_DIR) -I ../gl/

NAT_DEPS = ogamlGL.cmxa

BYT_DEPS = $(NAT_DEPS:.cmxa=.cma)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

MLLIB = ogamlWindow


# Do not remove the cmi generated from the mlipp file !

.PRECIOUS: %.cmi


# Compilation

default: .depend compile_window_nat compile_window_byte

compile_os_lib:
	cd $(OS_WIN_STUBS_DIR) && make

compile_window_nat: .depend compile_os_lib $(MLLIB).cmx
	$(OCAMLOPT) -a -o $(MLLIB).cmxa $(MLLIB).cmx -cclib -l$(strip $(OS_WIN_STUBS))

compile_window_byte: .depend compile_os_lib $(MLLIB).cmo
	$(OCAMLC) -a -o $(MLLIB).cma $(MLLIB).cmo -cclib -l$(strip $(OS_WIN_STUBS))

%.cmi:%.mli
	$(OCAMLC) -c -o $@ $(INCLUDE_DIRS) $(BYT_DEPS) $<

%.cmx:%.ml
	$(OCAMLOPT) -c -o $@ $(INCLUDE_DIRS) $(NAT_DEPS) $<

%.cmo:%.ml
	$(OCAMLC) -c -o $@ $(INCLUDE_DIRS) $(BYT_DEPS) $<

%.mli:%.mlipp 
	$(PPCOMMAND) -o $@ $<

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
