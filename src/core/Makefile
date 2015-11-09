include ../../common_defs.mk


# Stubs constants

COCOA_STUBS = application_delegate_stubs.m event_stubs.m glcontext_stubs.m\
	      utils_stubs.m window_stubs.m application_stubs.m opengl_stubs.m\
	      window_controller_stubs.m 

XLIB_STUBS = atoms_stubs.c display_stubs.c event_stubs.c glx_stubs.c\
	     mouse_stubs.c keyboard_stubs.c window_stubs.c 

UTILS_STUBS = stubs.c

OS_WIN_STUBS =

ifeq ($(OS_WIN_LIB), cocoa)
  OS_WIN_STUBS = $(COCOA_STUBS)
endif
ifeq ($(OS_WIN_LIB), x11)
  OS_WIN_STUBS = $(XLIB_STUBS)
endif

STUBS_SOURCES = $(addprefix $(OS_WIN_LIB)/$(STUBS_DIR)/, $(OS_WIN_STUBS)) 
	    
UTILS_SOURCES  =$(addprefix ../utils/, $(UTILS_STUBS))

STUBS_TARGETS = 

STUBS_OBJECTS = 

ifeq ($(OS_WIN_LIB), cocoa)
  STUBS_TARGETS = $(STUBS_SOURCES:.m=.o) $(UTILS_SOURCES:.c=.o)
  STUBS_OBJECTS = $(OS_WIN_STUBS:.m=.o) $(UTILS_STUBS:.c=.o)
endif
ifeq ($(OS_WIN_LIB), x11)
  STUBS_TARGETS = $(STUBS_SOURCES:.c=.o) $(UTILS_SOURCES:.c=.o)
  STUBS_OBJECTS = $(OS_WIN_STUBS:.c=.o) $(UTILS_STUBS:.c=.o)
endif


# ML constants

ML_SOURCES = LL.ml 

ML_INTERFACES = button.mli keycode.mli event.mli

ML_OBJ = $(ML_SOURCES:.ml=.cmo)

ML_NAT = $(ML_SOURCES:.ml=.cmx)

ML_CMIS = $(ML_INTERFACES:.mli=.cmi)


# Compilation

default: .depend core_lib

core_lib: ml_stubs $(STUBS_TARGETS) $(ML_CMIS) $(ML_OBJ) $(ML_NAT)
	$(OCAMLFIND) $(OCAMLOPT) -pack -o ogamlCore.cmx $(OS_WIN_LIB)/$(OS_WIN_LIB).cmx $(ML_CMIS) $(ML_NAT);
	$(OCAMLFIND) $(OCAMLC) -pack -o ogamlCore.cmo $(OS_WIN_LIB)/$(OS_WIN_LIB).cmo $(ML_CMIS) $(ML_OBJ);
	$(OCAMLFIND) $(OCAMLMKLIB) -o ogamlCore ogamlCore.cmx ogamlCore.cmo\
	  $(STUBS_OBJECTS) $(MKLIB_LIBS) $(GLOBAL_CLIBS)

ml_stubs: 
	cd $(OS_WIN_LIB) && make

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC) -c -o $@ $<

%.cmx:%.ml
	$(OCAMLFIND) $(OCAMLOPT) -c -for-pack OgamlCore -I $(OS_WIN_LIB)/ -o $@ $<

%.cmo:%.ml
	$(OCAMLFIND) $(OCAMLC) -c -for-pack OgamlCore -I $(OS_WIN_LIB)/ -o $@ $<

%.ml:%.mlpp %.cmi
	$(PPCOMMAND) -o $@ $<

%.o:%.m
	$(CLANG) -c -o ./$(notdir $@) $(OCAML_C_FLAGS) $(GLOBAL_OBJCOPTS) $(GLOBAL_CLIBS) $<

%.o:%.c
	$(OCAMLC) -c -o ./$(notdir $@) -cclib "$(GLOBAL_CLIBS)" $<


# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS);
	cd $(OS_WIN_LIB) && make clean


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli cocoa/*.ml cocoa/*.mli x11/*.ml x11/*.mli > .depend

include .depend

.PHONY: .depend

