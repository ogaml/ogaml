include ../../common_defs.mk

# Override

INCLUDE_DIRS = 

MLSOURCES = constants.ml vector2i.ml vector2f.ml vector3i.ml vector3f.ml\
	    intRect.ml floatRect.ml intBox.ml floatBox.ml\
	    quaternion.ml vector2fs.ml vector3fs.ml matrix3D.ml matrix2D.ml

MLINTERFACES =

MLOBJS = $(MLSOURCES:.ml=.cmo) 

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)


# Compilation

default: .depend compile_math_nat compile_math_byte

compile_math_nat: .depend $(MLCMIS) $(MLNATOBJS) ogamlMath.cmi
	$(OCAMLFIND) $(OCAMLOPT_CMD) -pack -o $(MATH_LIB).cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLFIND) $(OCAMLOPT_CMD) -a -o $(MATH_LIB).cmxa $(INCLUDE_DIRS) $(MATH_LIB).cmx

compile_math_byte: .depend $(MLCMIS) $(MLOBJS) ogamlMath.cmi
	$(OCAMLFIND) $(OCAMLC_CMD) -pack -o $(MATH_LIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLFIND) $(OCAMLC_CMD) -a -o $(MATH_LIB).cma $(INCLUDE_DIRS) $(MATH_LIB).cmo

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC_CMD) -c $< -o $@

%.cmx:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLOPT_CMD) -c -for-pack $(MATH_PACK) -o $@ $(INCLUDE_DIRS) $<

%.cmo:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLC_CMD) -c -for-pack $(MATH_PACK) -o $@ $(INCLUDE_DIRS) $<



# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend

