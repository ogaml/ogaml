include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../math/ -I ../core/

GRAPHICS_STUBS = shader_stubs.c program_stubs.c texture_stubs.c\
	         vao_stubs.c vbo_stubs.c uniform_stubs.c text_stubs.c\
		 render_stubs.c ebo_stubs.c image_stubs.c blending_stubs.c utils.c

STUBS_SRC = $(addprefix $(STUBS_DIR)/, $(GRAPHICS_STUBS))

STUBS_TARGET = $(STUBS_SRC:.c=.o)

STUBS_OBJS = $(GRAPHICS_STUBS:.c=.o)

MLSOURCES = color.ml drawParameter.ml GL.ml state.ml\
	    image.ml texture.ml program.ml uniform.ml window.ml indexArray.ml\
	    vertexArray.ml vertexMap.ml font.ml text.ml model.ml poly.ml shape.ml\
	    sprite.ml mouse.ml keyboard.ml

MLINTERFACES = drawMode.mli GLTypes.mli

MLOBJS = $(MLSOURCES:.ml=.cmo)

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMIS = $(MLINTERFACES:.mli=.cmi)

COPTS = -Wno-int-to-void-pointer-cast -Wno-int-to-pointer-cast -Wno-pointer-sign


# Compilation

default: .depend graphics_lib


graphics_lib: $(STUBS_TARGET) $(MLCMIS) $(MLOBJS) $(MLNATOBJS) ogamlGraphics.cmi
	$(OCAMLFIND) $(OCAMLC) -pack -o ogamlGraphics.cmo $(MLCMIS) $(MLOBJS);
	$(OCAMLFIND) $(OCAMLOPT) -pack -o ogamlGraphics.cmx $(MLCMIS) $(MLNATOBJS);
	$(OCAMLFIND) $(OCAMLMKLIB) -o ogamlGraphics $(STUBS_OBJS) ogamlGraphics.cmo ogamlGraphics.cmx\
	  $(MLOBJS) $(MLNATOBJS) $(GLOBAL_CLIBS)

%.cma:%.cmo
	$(OCAMLFIND) $(OCAMLC) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLFIND) $(OCAMLOPT) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) -for-pack OgamlGraphics $(INCLUDE_DIRS) ../core/ogamlCore.cma ../math/ogamlMath.cma -c $< -o $@

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) -for-pack OgamlGraphics $(INCLUDE_DIRS) ../core/ogamlCore.cmxa ../math/ogamlMath.cmxa -c $< -o $@

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) -for-pack OgamlGraphics $(INCLUDE_DIRS) ../core/ogamlCore.cma ../math/ogamlMath.cma -c $< -o $@

%.ml:%.mlpp %.cmi
	$(PPCOMMAND) -o $@ $<

%.o:%.c
	$(OCAMLFIND) $(OCAMLC) -o ./$(notdir $@) -c $< -ccopt '$(COPTS)' -cclib "$(GLOBAL_CLIBS)"




# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend
