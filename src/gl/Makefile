include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../utils/

CSOURCES = $(STUBS_DIR)/buffers_stubs.c ../utils/stubs.c

COBJS = $(CSOURCES:.c=.o)

COBJS2 = buffers_stubs.o stubs.o

MLSOURCES = buffers.ml

MLINTERFACES =

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

MLLIB = ogamlGL

LIBS = -cclib -lX11 -cclib -lGL



# Compilation

default: .depend $(MLLIB)


$(MLLIB): $(COBJS) $(MLOBJS) $(MLNATOBJS) $(MLCMIS)
	$(OCAMLFIND) $(OCAMLMKLIB) -o $(MLLIB) $(COBJS2) $(MLCMIS) $(MLOBJS) $(LIBS);
	$(OCAMLFIND) $(OCAMLMKLIB) -o $(MLLIB) $(COBJS2) $(MLCMIS) $(MLNATOBJS) $(LIBS)

%.cma:%.cmo 
	$(OCAMLFIND) $(OCAMLC) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLFIND) $(OCAMLOPT) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) -c -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) -c -o $@ $(INCLUDE_DIRS) $<

%.ml:%.mlpp %.cmi
	$(PPCOMMAND) -o $@ $<

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

