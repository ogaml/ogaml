include ../../common_defs.mk


INCLUDE_DIRS = -I ../math/ -I ../core/

# Stubs constants

COCOA_STUBS = application_delegate_stubs.m event_stubs.m glcontext_stubs.m\
	      utils_stubs.m window_stubs.m application_stubs.m opengl_stubs.m\
	      window_controller_stubs.m utils.m

XLIB_STUBS = atoms_stubs.c display_stubs.c event_stubs.c glx_stubs.c\
	     mouse_stubs.c keyboard_stubs.c window_stubs.c utils.c

OS_WIN_STUBS =

ifeq ($(OS_WIN_LIB), cocoa)
  OS_WIN_STUBS = $(COCOA_STUBS)
endif
ifeq ($(OS_WIN_LIB), x11)
  OS_WIN_STUBS = $(XLIB_STUBS)
endif

STUBS_SOURCES = $(addprefix $(OS_WIN_LIB)/$(STUBS_DIR)/, $(OS_WIN_STUBS)) 
	    
STUBS_TARGETS = 

STUBS_OBJECTS = 

ifeq ($(OS_WIN_LIB), cocoa)
  STUBS_TARGETS = $(STUBS_SOURCES:.m=.o)
  STUBS_OBJECTS = $(OS_WIN_STUBS:.m=.o)
endif
ifeq ($(OS_WIN_LIB), x11)
  STUBS_TARGETS = $(STUBS_SOURCES:.c=.o)
  STUBS_OBJECTS = $(OS_WIN_STUBS:.c=.o)
endif


# ML constants

ML_SOURCES = contextSettings.ml LL.ml

ML_INTERFACES = button.mli keycode.mli event.mli 

ML_OBJ = $(ML_SOURCES:.ml=.cmo)

ML_NAT = $(ML_SOURCES:.ml=.cmx)

ML_CMISALONE = $(ML_INTERFACES:.mli=.cmi)

ML_CMIS = $(ML_CMISALONE) $(ML_SOURCES:.ml=.cmi) 

# Compilation

default: .depend core_lib

core_lib: ml_stubs $(STUBS_TARGETS) $(ML_CMIS) $(ML_OBJ) $(ML_NAT) $(CORE_LIB).cmi
	$(OCAMLFIND) $(OCAMLOPT_CMD) -pack -o $(CORE_LIB).cmx $(OS_WIN_LIB)/$(OS_WIN_LIB).cmx $(ML_CMISALONE) $(ML_NAT) &&\
	$(OCAMLFIND) $(OCAMLC_CMD) -pack -o $(CORE_LIB).cmo $(OS_WIN_LIB)/$(OS_WIN_LIB).cmo $(ML_CMISALONE) $(ML_OBJ) &&\
	$(OCAMLFIND) $(OCAMLMKLIB) -o $(CORE_LIB) $(CORE_LIB).cmx $(CORE_LIB).cmo\
	  $(STUBS_OBJECTS) $(MKLIB_LIBS) $(GLOBAL_CLIBS)

ml_stubs: 
	cd $(OS_WIN_LIB) && make

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC_CMD) -c $(INCLUDE_DIRS) ../core/$(CORE_LIB).cma ../math/$(MATH_LIB).cma -o $@ $<

%.cmx:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLOPT_CMD) -c -for-pack $(CORE_PACK) $(INCLUDE_DIRS) ../core/$(CORE_LIB).cmxa ../math/$(MATH_LIB).cmxa -I $(OS_WIN_LIB)/ -o $@ $<

%.cmo:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLC_CMD) -c -for-pack $(CORE_PACK) $(INCLUDE_DIRS) ../core/$(CORE_LIB).cma ../math/$(MATH_LIB).cma -I $(OS_WIN_LIB)/ -o $@ $<

%.o:%.m
	$(CLANG) -c -o ./$(notdir $@) $(OCAML_C_FLAGS) $(GLOBAL_OBJCOPTS) $<

%.o:%.c
	$(OCAMLC_CMD) -c -o ./$(notdir $@) -cclib "$(GLOBAL_CLIBS)" $<


# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS) &\
	cd $(OS_WIN_LIB) && make clean


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli cocoa/*.ml cocoa/*.mli x11/*.ml x11/*.mli > .depend

include .depend

.PHONY: .depend

