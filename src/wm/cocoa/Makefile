include ../../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../../utils/

CSOURCES = $(STUBS_DIR)/utils_stubs.m\
	   $(STUBS_DIR)/glcontext_stubs.m\
	   $(STUBS_DIR)/opengl_stubs.m\
	   $(STUBS_DIR)/application_stubs.m\
		 $(STUBS_DIR)/application_delegate_stubs.m\
		 $(STUBS_DIR)/window_stubs.m\
		 $(STUBS_DIR)/window_controller_stubs.m\
		 $(STUBS_DIR)/event_stubs.m\
	   ../../utils/stubs.c

COBJS = $(CSOURCES:.c=.o) $(CSOURCES:.m=.o)

COBJS2 = utils_stubs.o glcontext_stubs.o opengl_stubs.o application_stubs.o\
 	       application_delegate_stubs.o window_stubs.o window_controller_stubs.o\
				 event_stubs.o stubs.o

MLSOURCES = cocoa.ml cocoa.mli

MLOBJS = $(MLSOURCES:.ml=.cmx)

CLIB = cocoa_stubs

ifeq ($(OS_NAME), LINUX)
  COPTS = -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNU_RUNTIME=1 -DGNUSTEP_BASE_LIBRARY=1 -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -pthread -fPIC -Wall -DGSWARN -DGSDIAGNOSE -Wno-import -g -O2 -fgnu-runtime -fconstant-string-class=NSConstantString -I. -I/home/victor/GNUstep/Library/Headers -I/usr/local/include/GNUstep -I/usr/include/GNUstep
  LIBS  = -rdynamic -shared-libgcc -pthread -fexceptions -fgnu-runtime -L/home/victor/GNUstep/Library/Libraries -L/usr/local/lib -L/usr/lib -lgnustep-gui -lgnustep-base -lobjc -lm
endif
ifeq ($(OS_NAME), OSX)
  COPTS = -fconstant-string-class=NSConstantString
  LIBS = -framework Foundation -framework Cocoa -lobjc
endif



# Compilation

default: .depend $(CLIB)

$(CLIB): $(COBJS) $(MLOBJS)
	$(OCAMLMKLIB) -o $(CLIB) -v -ccopt '"$(LIBS)"' $(COBJS2) $(MLOBJS)

%.cmi:%.mli
	$(OCAMLC) -c $< -o $@

%.cmx:%.ml
	$(OCAMLOPT) -c $< -o $@ -cclib '$(LIBS)'

%.cmo:%.ml
	$(OCAMLC) -c $< -o $@ -cclib '$(LIBS)'

%.o:%.m
	$(CLANG) -c $(CCOMPIL_FLAGS) $(COPTS) $<

%.o:%.c
	$(OCAMLC) -c $<


# Cleaning

clean:
	rm -rf $(EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend
