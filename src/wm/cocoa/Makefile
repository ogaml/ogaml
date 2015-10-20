include ../../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../../utils/

CSOURCES = $(STUBS_DIR)/utils_stubs.m $(STUBS_DIR)/application_stubs.m\
	   $(STUBS_DIR)/test_stubs.m ../../utils/stubs.c

COBJS = $(CSOURCES:.c=.o)

COBJS2 = utils_stubs.o application_stubs.o test_stubs.o stubs.o

MLSOURCES = cocoa.ml cocoa.mli

MLOBJS = $(MLSOURCES:.ml=.cmx)

CLIB = cocoa_stubs

COPTS = -fconstant-string-class=NSConstantString

LIBS = -framework Foundation -framework Cocoa -lobjc


# Compilation

default: depend $(CLIB)

$(CLIB): $(COBJS) $(MLOBJS)
	$(OCAMLMKLIB) -o $(CLIB) -v -ccopt '"$(LIBS)"' $(COBJS2) $(MLOBJS)

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c $< -o $@ -cclib '$(LIBS)'

%.cmo:%.ml
	$(OCAMLC) -c $< -o $@ -cclib '$(LIBS)'


%.o:%.m
	$(OCAMLC) -c -ccopt '$(COPTS)' $< -o $@

%.o:%.c
	$(OCAMLC) -c -ccopt '$(COPTS)' $< -o $@


# Cleaning

clean:
	rm -rf $(EXTENSIONS)


# Dependencies

depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend
