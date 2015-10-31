include ../../common_defs.mk

# Override

INCLUDE_DIRS = 

MLSOURCES = constants.ml vector3i.ml vector3f.ml quaternion.ml vector3fs.ml matrix3D.ml poly.ml

MLINTERFACES =

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

MLLIB = ogamlMath

PACKNAME = OgamlMath



# Compilation

default: .depend compile_math_nat compile_math_byte

compile_math_nat: .depend $(MLCMIS) $(MLNATOBJS)
	$(OCAMLOPT) -pack -o $(MLLIB).cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLOPT) -a -o $(MLLIB).cmxa $(INCLUDE_DIRS) $(MLLIB).cmx

compile_math_byte: .depend $(MLCMIS) $(MLOBJS)
	$(OCAMLC) -pack -o $(MLLIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLC) -a -o $(MLLIB).cma $(INCLUDE_DIRS) $(MLLIB).cmo

%.cma:%.cmo 
	$(OCAMLC) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLOPT) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c -for-pack $(PACKNAME) -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml
	$(OCAMLC) -c -for-pack $(PACKNAME) -o $@ $(INCLUDE_DIRS) $<

%.ml:%.mlpp %.cmi
	$(PPCOMMAND) -o $@ $<



# Cleaning

clean:
	rm -rf $(EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend

