include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../math/ -I ../core/ -I ../utils/

GRAPHICS_STUBS = shader_stubs.c program_stubs.c texture_stubs.c\
	         vao_stubs.c vbo_stubs.c uniform_stubs.c text_stubs.c\
		 render_stubs.c ebo_stubs.c image_stubs.c blending_stubs.c utils.c

STUBS_SRC = $(addprefix $(STUBS_DIR)/, $(GRAPHICS_STUBS))

STUBS_TARGET = $(STUBS_SRC:.c=.o)

STUBS_OBJS = $(GRAPHICS_STUBS:.c=.o)

LEXER_FILES = objLexer.mll

PARSER_FILES = objParser.mly

MLSOURCES = color.ml drawParameter.ml GL.ml state.ml\
	    image.ml texture.ml program.ml uniform.ml programLibrary.ml\
	    window.ml indexArray.ml\
	    vertexArray.ml vertexMap.ml font.ml text.ml\
	    $(PARSER_FILES:.mly=.ml) $(LEXER_FILES:.mll=.ml)\
	    model.ml shape.ml sprite.ml mouse.ml keyboard.ml 

MLINTERFACES = drawMode.mli GLTypes.mli objAST.mli

MLOBJS = $(MLSOURCES:.ml=.cmo)

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMISALONE = $(MLINTERFACES:.mli=.cmi)

MLCMIS = $(MLCMISALONE) $(MLSOURCES:.ml=.cmi)

COPTS = -Wno-int-to-void-pointer-cast -Wno-int-to-pointer-cast -Wno-pointer-sign

CMA_DEPS = ../core/$(CORE_LIB).cma ../math/$(MATH_LIB).cma ../utils/$(UTILS_LIB).cma
CMXA_DEPS = ../core/$(CORE_LIB).cmxa ../math/$(MATH_LIB).cmxa ../utils/$(UTILS_LIB).cmxa


# Compilation

.INTERMEDIATE: $(LEXER_FILES:.mll=.ml) $(PARSER_FILES:.mly=.ml) $(PARSER_FILES:.mly=.mli)

default: .depend graphics_lib


graphics_lib: $(STUBS_TARGET) $(MLCMIS) $(MLOBJS) $(MLNATOBJS) $(GRAPHICS_LIB).cmi
	$(OCAMLFIND) $(OCAMLC_CMD) -pack -o $(GRAPHICS_LIB).cmo $(MLCMISALONE) $(MLOBJS) &&\
	$(OCAMLFIND) $(OCAMLOPT_CMD) -pack -o $(GRAPHICS_LIB).cmx $(MLCMISALONE) $(MLNATOBJS) &&\
	$(OCAMLFIND) $(OCAMLMKLIB) -o $(GRAPHICS_LIB) $(STUBS_OBJS) $(GRAPHICS_LIB).cmo $(GRAPHICS_LIB).cmx\
	  $(MLOBJS) $(MLNATOBJS) $(GLOBAL_CLIBS)

%.cma:%.cmo
	$(OCAMLFIND) $(OCAMLC_CMD) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLFIND) $(OCAMLOPT_CMD) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC_CMD) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.cmx:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLOPT_CMD) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMXA_DEPS) -c $< -o $@

%.cmo:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLC_CMD) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.ml:%.mll
	$(LEX) $<

%.mli:%.mll

%.ml:%.mly
	$(MENHIR) $<

%.mli:%.mly
	$(MENHIR) $<

%.o:%.c
	$(OCAMLFIND) $(OCAMLC_CMD) -o ./$(notdir $@) -c $< -ccopt '$(COPTS)' -cclib "$(GLOBAL_CLIBS)"




# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend &&\
	$(MENHIR) --depend *.mly >> .depend

include .depend

.PHONY: .depend
