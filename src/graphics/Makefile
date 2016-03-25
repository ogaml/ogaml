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

MLCMIS = $(MLINTERFACES:.mli=.cmi)

COPTS = -Wno-int-to-void-pointer-cast -Wno-int-to-pointer-cast -Wno-pointer-sign

CMA_DEPS = ../core/$(CORE_LIB).cma ../math/$(MATH_LIB).cma ../utils/$(UTILS_LIB).cma
CMXA_DEPS = ../core/$(CORE_LIB).cmxa ../math/$(MATH_LIB).cmxa ../utils/$(UTILS_LIB).cmxa


# Compilation

.INTERMEDIATE: $(LEXER_FILES:.mll=.ml) $(PARSER_FILES:.mly=.ml) $(PARSER_FILES:.mly=.mli)

default: .depend graphics_lib


graphics_lib: $(STUBS_TARGET) $(MLCMIS) $(MLOBJS) $(MLNATOBJS) $(GRAPHICS_LIB).cmi
	$(OCAMLFIND) $(OCAMLC) -pack -o $(GRAPHICS_LIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLFIND) $(OCAMLOPT) -pack -o $(GRAPHICS_LIB).cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLFIND) $(OCAMLMKLIB) -o $(GRAPHICS_LIB) $(STUBS_OBJS) $(GRAPHICS_LIB).cmo $(GRAPHICS_LIB).cmx\
	  $(MLOBJS) $(MLNATOBJS) $(GLOBAL_CLIBS)

%.cma:%.cmo
	$(OCAMLFIND) $(OCAMLC) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLFIND) $(OCAMLOPT) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMXA_DEPS) -c $< -o $@

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.ml:%.mll
	$(LEX) $<

%.ml:%.mly
	$(MENHIR) $<

%.mli:%.mly
	$(MENHIR) $<

%.ml:%.mlpp %.cmi
	$(PPCOMMAND) -o $@ $<

%.o:%.c
	$(OCAMLFIND) $(OCAMLC) -o ./$(notdir $@) -c $< -ccopt '$(COPTS)' -cclib "$(GLOBAL_CLIBS)"




# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend;
	$(MENHIR) --depend *.mly >> .depend

include .depend

.PHONY: .depend
