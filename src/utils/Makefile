include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../math/

MLSOURCES = priorityQueue.ml dequeue.ml graph.ml interpolator.ml noise.ml UTF8String.ml log.ml

MLINTERFACES =

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

MLLIB = ogamlUtils

PACKNAME = OgamlUtils


# Compilation

default: .depend compile_utils_nat compile_utils_byte

compile_utils_nat: .depend $(MLCMIS) $(MLNATOBJS) ogamlUtils.cmi
	$(OCAMLFIND) $(OCAMLOPT) -pack -o $(MLLIB).cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLFIND) $(OCAMLOPT) -a -o $(MLLIB).cmxa $(INCLUDE_DIRS) $(MLLIB).cmx

compile_utils_byte: .depend $(MLCMIS) $(MLOBJS) ogamlUtils.cmi
	$(OCAMLFIND) $(OCAMLC) -pack -o $(MLLIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLFIND) $(OCAMLC) -a -o $(MLLIB).cma $(INCLUDE_DIRS) $(MLLIB).cmo

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) $(INCLUDE_DIRS) ../math/ogamlMath.cma -c $< -o $@

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) $(INCLUDE_DIRS) ../math/ogamlMath.cmxa -c -for-pack $(PACKNAME) -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) $(INCLUDE_DIRS) ../math/ogamlMath.cma -c -for-pack $(PACKNAME) -o $@ $(INCLUDE_DIRS) $<

%.ml:%.mlpp %.cmi
	$(PPCOMMAND) -o $@ $<



# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend

