include ../../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../../utils/

CSOURCES = $(STUBS_DIR)/atoms_stubs.c $(STUBS_DIR)/display_stubs.c\
	   $(STUBS_DIR)/event_stubs.c $(STUBS_DIR)/window_stubs.c\
	   $(STUBS_DIR)/glx_stubs.c ../../utils/stubs.c

COBJS = $(CSOURCES:.c=.o)

COBJS2 = atoms_stubs.o display_stubs.o event_stubs.o window_stubs.o glx_stubs.o stubs.o

MLSOURCES = xlib.ml

MLOBJS = $(MLSOURCES:.ml=.cmx)

CLIB = xlib_stubs

COPTS = 

LIBS = -cclib -lX11 -cclib -lGL


# Compilation

default: .depend $(CLIB)

$(CLIB): $(COBJS) $(MLOBJS)
	$(OCAMLFIND) $(OCAMLMKLIB) -o $(CLIB) $(COBJS2) $(MLOBJS) $(LIBS)

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) -c $< -o $@ $(LIBS)

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) -c $< -o $@ $(LIBS)


%.o:%.c
	$(OCAMLFIND) $(OCAMLC) -c -ccopt '$(COPTS)' $<



# Cleaning

clean:
	rm -rf $(EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend
