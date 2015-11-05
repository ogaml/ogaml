include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../utils/ -I ../math/

CSOURCES = $(STUBS_DIR)/buffers_stubs.c $(STUBS_DIR)/shader_stubs.c\
	   $(STUBS_DIR)/error_stubs.c $(STUBS_DIR)/config_stubs.c\
	   $(STUBS_DIR)/program_stubs.c $(STUBS_DIR)/uniform_stubs.c\
	   $(STUBS_DIR)/state_stubs.c $(STUBS_DIR)/texture_stubs.c\
	   ../utils/stubs.c

COBJS = $(CSOURCES:.c=.o)

COBJS2 = buffers_stubs.o shader_stubs.o error_stubs.o config_stubs.o\
	 program_stubs.o stubs.o uniform_stubs.o state_stubs.o\
	 texture_stubs.o

MLSOURCES = color.ml config.ml error.ml internal.ml state.ml program.ml buffers.ml image.ml texture.ml uniform.ml

MLINTERFACES = enum.mli

MLOBJS = $(MLSOURCES:.ml=.cmo)

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

MLLIB = ogamlGL

PACKNAME = OgamlGL

COPTS = -Wno-int-to-void-pointer-cast -Wno-int-to-pointer-cast -Wno-pointer-sign

LIBS =

ifeq ($(OS_NAME), LINUX)
  LIBS = -lGL
endif
ifeq ($(OS_NAME), OSX)
  LIBS = -framework openGL
endif



# Compilation

default: .depend $(MLLIB)


$(MLLIB): $(COBJS) $(MLCMIS) $(MLOBJS) $(MLNATOBJS)
	$(OCAMLFIND) $(OCAMLC) -pack -o $(MLLIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLFIND) $(OCAMLOPT) -pack -o $(MLLIB).cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLFIND) $(OCAMLMKLIB) -o $(MLLIB) $(COBJS2) $(MLLIB).cmo $(LIBS);
	$(OCAMLFIND) $(OCAMLMKLIB) -o $(MLLIB) $(COBJS2) $(MLLIB).cmx $(MLNATOBJS) $(LIBS)

%.cma:%.cmo
	$(OCAMLFIND) $(OCAMLC) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLFIND) $(OCAMLOPT) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) -for-pack $(PACKNAME) $(INCLUDE_DIRS) ../math/ogamlMath.cma -c $< -o $@

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) -for-pack $(PACKNAME) $(INCLUDE_DIRS) ../math/ogamlMath.cmxa -c $< -o $@ 

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) -for-pack $(PACKNAME) $(INCLUDE_DIRS) ../math/ogamlMath.cma -c $< -o $@ 

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
