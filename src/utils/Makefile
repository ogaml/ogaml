include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../math/

MLSOURCES = priorityQueue.ml dequeue.ml graph.ml interpolator.ml noise.ml UTF8String.ml log.ml clock.ml

MLINTERFACES =

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMISALONE = $(MLINTERFACES:.mli=.cmi)

MLCMIS = $(MLCMISALONE) $(MLSOURCES:.ml=.cmi)


# Compilation

default: compile_utils_nat compile_utils_byte

compile_utils_nat: $(MLCMIS) $(MLNATOBJS) ogamlUtils.cmi
	$(OCAMLFIND) $(OCAMLOPT_CMD) -pack -o $(UTILS_LIB).cmx $(MLCMISALONE) $(MLNATOBJS) &&\
	$(OCAMLFIND) $(OCAMLOPT_CMD) -a -o $(UTILS_LIB).cmxa $(INCLUDE_DIRS) $(UTILS_LIB).cmx

compile_utils_byte: $(MLCMIS) $(MLOBJS) ogamlUtils.cmi
	$(OCAMLFIND) $(OCAMLC_CMD) -pack -o $(UTILS_LIB).cmo $(MLCMISALONE) $(MLOBJS) &&\
	$(OCAMLFIND) $(OCAMLC_CMD) -a -o $(UTILS_LIB).cma $(INCLUDE_DIRS) $(UTILS_LIB).cmo

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC_CMD) $(INCLUDE_DIRS) ../math/$(MATH_LIB).cma -c $< -o $@

%.cmx:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLOPT_CMD) $(INCLUDE_DIRS) ../math/$(MATH_LIB).cmxa -c -for-pack $(UTILS_PACK) -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLC_CMD) $(INCLUDE_DIRS) ../math/$(MATH_LIB).cma -c -for-pack $(UTILS_PACK) -o $@ $(INCLUDE_DIRS) $<



# Cleaning

clean:
	rm -f $(CLEAN_EXTENSIONS)


# Dependencies

depend:.depend

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

.PHONY: .depend

