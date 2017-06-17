OCAMLC_DIR = $(shell $(OCAMLC) -where)

OBJC_FLAGS = -Wall -D_FILE_OFFSET_BITS=64 -D_REENTRANT -fPIC -I '$(OCAML_DIR)'\
             -Wno-unused-function -Wno-unused-variable\
             -Wno-misleading-indentation-fconstant-string-class=NSConstantString

OBJC_FILES = application_delegate_stubs.m event_stubs.m window_stubs.m\
             application_stubs.m glcontext_stubs.m utils_stubs.m opengl_stubs.m\
             window_controller_stubs.m

OBJC_OBJECTS = $(OBJC_FILES:.m=.o)

default: cocoa_lib_stubs

cocoa_lib_stubs: $(OBJC_OBJECTS)
	ocamlmklib -o OgamlCore_stubs $(OBJC_OBJECTS)

%.o:%.m
	clang -c -o $@ $(OBJC_FLAGS) $<

.PHONY: cocoa_lib_stubs
