include ../../common_defs.mk

# Override

INCLUDE_DIRS = 

MLSOURCES = constants.ml vector2i.ml vector2f.ml vector3i.ml vector3f.ml\
	    quaternion.ml vector3fs.ml matrix3D.ml 

MLINTERFACES =

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

MLLIB = ogamlMath

PACKNAME = OgamlMath


# Compilation

default: .depend compile_math_nat compile_math_byte

compile_math_nat: .depend $(MLCMIS) $(MLNATOBJS) ogamlMath.cmi
	$(OCAMLFIND) $(OCAMLOPT) -pack -o $(MLLIB).cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLFIND) $(OCAMLOPT) -a -o $(MLLIB).cmxa $(INCLUDE_DIRS) $(MLLIB).cmx

compile_math_byte: .depend $(MLCMIS) $(MLOBJS) ogamlMath.cmi
	$(OCAMLFIND) $(OCAMLC) -pack -o $(MLLIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLFIND) $(OCAMLC) -a -o $(MLLIB).cma $(INCLUDE_DIRS) $(MLLIB).cmo

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) -c -for-pack $(PACKNAME) -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) -c -for-pack $(PACKNAME) -o $@ $(INCLUDE_DIRS) $<

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

