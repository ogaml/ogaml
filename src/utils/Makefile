include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../math/

MLSOURCES = priorityQueue.ml dequeue.ml graph.ml interpolator.ml noise.ml UTF8String.ml log.ml

MLINTERFACES =

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)


# Compilation

default: .depend compile_utils_nat compile_utils_byte

compile_utils_nat: .depend $(MLCMIS) $(MLNATOBJS) ogamlUtils.cmi
	$(OCAMLFIND) $(OCAMLOPT) -pack -o $(UTILS_LIB).cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLFIND) $(OCAMLOPT) -a -o $(UTILS_LIB).cmxa $(INCLUDE_DIRS) $(UTILS_LIB).cmx

compile_utils_byte: .depend $(MLCMIS) $(MLOBJS) ogamlUtils.cmi
	$(OCAMLFIND) $(OCAMLC) -pack -o $(UTILS_LIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLFIND) $(OCAMLC) -a -o $(UTILS_LIB).cma $(INCLUDE_DIRS) $(UTILS_LIB).cmo

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) $(INCLUDE_DIRS) ../math/$(MATH_LIB).cma -c $< -o $@

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) $(INCLUDE_DIRS) ../math/$(MATH_LIB).cmxa -c -for-pack $(UTILS_PACK) -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) $(INCLUDE_DIRS) ../math/$(MATH_LIB).cma -c -for-pack $(UTILS_PACK) -o $@ $(INCLUDE_DIRS) $<

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

