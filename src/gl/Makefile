include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../utils/

CSOURCES = $(STUBS_DIR)/buffers_stubs.c $(STUBS_DIR)/shader_stubs.c\
	   $(STUBS_DIR)/error_stubs.c ../utils/stubs.c

COBJS = $(CSOURCES:.c=.o)

COBJS2 = buffers_stubs.o shader_stubs.o error_stubs.o stubs.o

MLSOURCES = buffer.ml shader.ml error.ml

MLINTERFACES =

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

MLLIB = ogamlGL

LIBS = -cclib -lX11 -cclib -lGL



# Compilation

default: .depend $(MLLIB)


$(MLLIB): $(COBJS) $(MLCMIS) $(MLOBJS) $(MLNATOBJS) 
	$(OCAMLMKLIB) -o $(MLLIB) $(COBJS2) $(MLCMIS) $(MLOBJS) $(LIBS);
	$(OCAMLMKLIB) -o $(MLLIB) $(COBJS2) $(MLCMIS) $(MLNATOBJS) $(LIBS)

%.cma:%.cmo 
	$(OCAMLC) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLOPT) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml
	$(OCAMLC) -c -o $@ $(INCLUDE_DIRS) $<

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

