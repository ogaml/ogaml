include ../../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../../utils/

CSOURCES = $(STUBS_DIR)/utils_stubs.c $(STUBS_DIR)/application_stubs.c\
	   $(STUBS_DIR)/test_stubs.c ../../utils/stubs.c

COBJS = $(CSOURCES:.c=.o)

COBJS2 = utils_stubs.o application_stubs.o test_stubs.o stubs.o

MLSOURCES = cocoa.ml cocoa.mli

MLOBJS = $(MLSOURCES:.ml=.cmx)

CLIB = cocoa_stubs

COPTS = -fconstant-string-class=NSConstantString -x objective-c

LIBS = -framework Foundation -framework Cocoa -lobjc


# Compilation

default: depend $(CLIB)

$(CLIB): $(COBJS) $(MLOBJS)
	$(OCAMLMKLIB) -o $(CLIB) $(COBJS2) $(MLOBJS)

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c $< -o $@ -cclib '$(LIBS)'

%.cmo:%.ml
	$(OCAMLC) -c $< -o $@ -cclib '$(LIBS)'


%.o:%.c
	$(OCAMLC) -c -ccopt '$(COPTS)' -ccopt '$(LIBS)' $< -o $@ 



# Cleaning

clean:
	rm -rf $(EXTENSIONS)


# Dependencies

depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend


