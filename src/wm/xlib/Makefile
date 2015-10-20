include ../../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../../utils/

CSOURCES = $(STUBS_DIR)/atoms_stubs.c $(STUBS_DIR)/display_stubs.c\
	   $(STUBS_DIR)/event_stubs.c $(STUBS_DIR)/window_stubs.c ../../utils/stubs.c

COBJS = $(CSOURCES:.c=.o)

COBJS2 = atoms_stubs.o display_stubs.o event_stubs.o window_stubs.o stubs.o

MLSOURCES = xlib.ml xlib.mli

MLOBJS = $(MLSOURCES:.ml=.cmx)

CLIB = xlib_stubs

COPTS = 

LIBS = -lX11


# Compilation

default: .depend $(CLIB)

$(CLIB): $(COBJS) $(MLOBJS)
	$(OCAMLMKLIB) -o $(CLIB) $(COBJS2) $(MLOBJS) -ccopt '$(LIBS)'

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c $< -o $@ -cclib '$(LIBS)'

%.cmo:%.ml
	$(OCAMLC) -c $< -o $@ -cclib '$(LIBS)'


%.o:%.c
	$(OCAMLC) -c -ccopt '$(COPTS)' $<



# Cleaning

clean:
	rm -rf $(EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend


