include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../math/ -I ../core/ -I ../utils/\
	       -I 2d/ -I backend/ -I fbo/ -I program/ -I texture/ -I vertex/\
	       -I model/ -I window/

GRAPHICS_STUBS = shader_stubs.c program_stubs.c texture_stubs.c\
	   vao_stubs.c vbo_stubs.c uniform_stubs.c text_stubs.c\
		 render_stubs.c ebo_stubs.c image_stubs.c blending_stubs.c\
		 fbo_stubs.c rbo_stubs.c types_stubs.c

STUBS_SRC = $(addprefix $(STUBS_DIR)/, $(GRAPHICS_STUBS))

STUBS_TARGET = $(STUBS_SRC:.c=.o)

STUBS_OBJS = $(GRAPHICS_STUBS:.c=.o)

LEXER_FILES = model/objLexer.mll

PARSER_FILES = model/objParser.mly

MLSOURCES = backend/color.ml\
		backend/GLTypes.ml\
		backend/drawParameter.ml\
	    backend/GL.ml\
	    backend/programInternal.ml\
	    backend/context.ml\
	    fbo/renderTarget.ml\
	    fbo/attachment.ml\
	    fbo/renderbuffer.ml\
	    fbo/framebuffer.ml\
	    texture/image.ml\
	    texture/texture.ml\
	    program/program.ml\
	    program/uniform.ml\
	    vertex/indexArray.ml\
	    vertex/vertexArray.ml\
	    $(PARSER_FILES:.mly=.ml)\
	    $(LEXER_FILES:.mll=.ml)\
	    model/model.ml\
	    2d/font.ml\
	    2d/text.ml\
	    2d/shape.ml\
	    2d/sprite.ml\
	    window/window.ml\
	    window/mouse.ml\
	    window/keyboard.ml

MLINTERFACES = vertex/drawMode.mli model/objAST.mli

MLOBJS = $(MLSOURCES:.ml=.cmo)

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMISALONE = $(MLINTERFACES:.mli=.cmi)

MLCMIS = $(MLCMISALONE) $(PARSER_FILES:.mly=.cmi) $(LEXER_FILES:.mll=.cmi) $(MLSOURCES:.ml=.cmi)

COPTS = -Wno-int-to-void-pointer-cast -Wno-int-to-pointer-cast -Wno-pointer-sign -Wno-unused-function -Wno-unused-variable -Wno-misleading-indentation

CMA_DEPS = ../core/$(CORE_LIB).cma ../math/$(MATH_LIB).cma ../utils/$(UTILS_LIB).cma
CMXA_DEPS = ../core/$(CORE_LIB).cmxa ../math/$(MATH_LIB).cmxa ../utils/$(UTILS_LIB).cmxa


# Lib compilation 

ifeq ($(OS_NAME), WIN)
    LIB_CMD = \
        $(OCAMLFIND) $(OCAMLC_CMD) -a -o $(GRAPHICS_LIB).cma $(GRAPHICS_LIB).cmo\
            -cclib -l$(GRAPHICS_LIB) -cclib "$(GLOBAL_CLIBS)" &&\
        $(OCAMLFIND) $(OCAMLOPT_CMD) -a -o $(GRAPHICS_LIB).cmxa $(GRAPHICS_LIB).cmx\
            -cclib -l$(GRAPHICS_LIB) -cclib "$(GLOBAL_CLIBS)"&&\
        lib -out:lib$(GRAPHICS_LIB).lib $(STUBS_OBJS)
else
    LIB_CMD =\
        $(OCAMLFIND) $(OCAMLMKLIB) -o $(GRAPHICS_LIB) $(STUBS_OBJS) $(GRAPHICS_LIB).cmo $(GRAPHICS_LIB).cmx\
            $(MLOBJS) $(MLNATOBJS) $(GLOBAL_CLIBS)
endif


# Compilation

.INTERMEDIATE: $(LEXER_FILES:.mll=.ml) $(PARSER_FILES:.mly=.ml) objParser.mli

default: graphics_lib

graphics_lib: $(STUBS_TARGET) $(MLCMIS) $(MLOBJS) $(MLNATOBJS) $(GRAPHICS_LIB).cmi
	$(OCAMLFIND) $(OCAMLC_CMD) -pack -o $(GRAPHICS_LIB).cmo $(MLCMISALONE) $(MLOBJS) &&\
	$(OCAMLFIND) $(OCAMLOPT_CMD) -pack -o $(GRAPHICS_LIB).cmx $(MLCMISALONE) $(MLNATOBJS) &&\
	$(LIB_CMD)

%.cma:%.cmo
	$(OCAMLFIND) $(OCAMLC_CMD) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLFIND) $(OCAMLOPT_CMD) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC_CMD) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.cmi:%.ml
	$(OCAMLFIND) $(OCAMLC_CMD) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.cmx:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLOPT_CMD) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMXA_DEPS) -c $< -o $@
 
%.cmo:%.ml $(wildcard %.mli)
	$(OCAMLFIND) $(OCAMLC_CMD) -for-pack $(GRAPHICS_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.ml:%.mll
	$(LEX) $<

%.cmi:%.mll %.ml
	$(OCAMLC_CMD) -c $(<:.mll=.ml)

%.ml:%.mly
	$(MENHIR) $<

%.mli:%.mly
	$(MENHIR) $<

%.o:%.c
	$(OCAMLFIND) $(OCAMLC_CMD) -o ./$(notdir $@) -c $< -ccopt "$(COPTS)" -cclib "$(GLOBAL_CLIBS)"


# Cleaning

clean:
	make -C 2d/ clean &\
	make -C backend/ clean &\
	make -C fbo/ clean &\
	make -C model/ clean &\
	make -C program/ clean &\
	make -C texture/ clean &\
	make -C vertex/ clean &\
	make -C window/ clean &\
	rm -f $(CLEAN_EXTENSIONS) &\
	rm -f objLexer.ml objParser.ml objParser.mli &\
	rm -f .depend


# Dependencies

depend:.depend

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend


.PHONY: .depend
