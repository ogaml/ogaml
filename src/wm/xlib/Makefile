include ../../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../../utils/

CSOURCES = $(STUBS_DIR)/atoms_stubs.c $(STUBS_DIR)/display_stubs.c\
	   $(STUBS_DIR)/event_stubs.c $(STUBS_DIR)/window_stubs.c ../../utils/stubs.c

COBJS = $(CSOURCES:.c=.o)

COBJS2 = atoms_stubs.o display_stubs.o event_stubs.o window_stubs.o stubs.o

MLSOURCES = xlib.ml xlib.mli

MLOBJS = $(MLSOURCES:.ml=.cmo)

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

CLIB = xlib_stubs.a


# Compilation

default: depend $(CLIB)

xlib_stubs.a: $(COBJS) $(MLOBJS)
	$(OCAMLMKLIB) -o xlib_stubs $(COBJS2) $(MLOBJS) -lX11

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c $< -o $@ -cclib -lX11

%.cmo:%.ml
	$(OCAMLC) -c $< -o $@ -cclib -lX11


%.o:%.c
	$(OCAMLC) -c $< -o $@



# Cleaning

clean:
	rm -rf $(EXTENSIONS)


# Dependencies

depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend


