include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../math/ -I ../core/ -I ../utils/\
	       -I 2d/ -I backend/ -I fbo/ -I program/ -I texture/ -I vertex/\
	       -I model/

GRAPHICS_STUBS = shader_stubs.c program_stubs.c texture_stubs.c\
	         vao_stubs.c vbo_stubs.c uniform_stubs.c text_stubs.c\
		 render_stubs.c ebo_stubs.c image_stubs.c blending_stubs.c\
		 fbo_stubs.c rbo_stubs.c utils.c\
		 types_stubs.c

STUBS_SRC = $(addprefix $(STUBS_DIR)/, $(GRAPHICS_STUBS))

STUBS_TARGET = $(STUBS_SRC:.c=.o)

STUBS_OBJS = $(GRAPHICS_STUBS:.c=.o)

LEXER_FILES = model/objLexer.mll

PARSER_FILES = model/objParser.mly

MLSOURCES = 2d/color.ml\
	    backend/GLTypes.ml\
	    vertex/drawParameter.ml\
	    backend/GL.ml\
	    program/programInternal.ml\
	    backend/state.ml\
	    fbo/renderTarget.ml\
	    texture/image.ml\
	    texture/texture.ml\
	    program/program.ml\
	    2d/font.ml\
	    program/uniform.ml\
	    backend/window.ml\
	    vertex/indexArray.ml\
	    vertex/vertexArray.ml\
	    vertex/vertexMap.ml\
	    2d/text.ml\
	    $(PARSER_FILES:.mly=.ml)\
	    $(LEXER_FILES:.mll=.ml)\
	    model/model.ml\
	    2d/shape.ml\
	    2d/sprite.ml\
	    backend/mouse.ml\
	    backend/keyboard.ml

MLINTERFACES = vertex/drawMode.mli model/objAST.mli

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
	$(OCAMLFIND) $(OCAMLC_CMD) -pack -o $(GRAPHICS_LIB).cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLFIND) $(OCAMLOPT_CMD) -pack -o $(GRAPHICS_LIB).cmx $(MLCMIS) $(MLNATOBJS);
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
	cd 2d/ && rm -f $(CLEAN_EXTENSIONS);
	cd backend/ && rm -f $(CLEAN_EXTENSIONS);
	cd fbo/ && rm -f $(CLEAN_EXTENSIONS);
	cd model/ && rm -f $(CLEAN_EXTENSIONS);
	cd program/ && rm -f $(CLEAN_EXTENSIONS);
	cd texture/ && rm -f $(CLEAN_EXTENSIONS);
	cd vertex/ && rm -f $(CLEAN_EXTENSIONS);
	rm -f $(CLEAN_EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) */*.ml */*.mli > .depend;
	$(MENHIR) --depend */*.mly >> .depend

include .depend

.PHONY: .depend
