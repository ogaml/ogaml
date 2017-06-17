OCAMLC_DIR = $(shell $(OCAMLC) -where)

OBJC_FLAGS = -Wall -D_FILE_OFFSET_BITS=64 -D_REENTRANT -fPIC -I '$(OCAML_DIR)'\
             -Wno-unused-function -Wno-unused-variable\
             -Wno-misleading-indentation -fconstant-string-class=NSConstantString

C_FLAGS = -Wno-unused-function -Wno-unused-variable\
          -Wno-misleading-indentation

OBJC_FILES = application_delegate_stubs.m event_stubs.m window_stubs.m\
             application_stubs.m glcontext_stubs.m utils_stubs.m opengl_stubs.m\
             window_controller_stubs.m

C_FILES = utils.c

OBJC_OBJECTS = $(OBJC_FILES:.m=.o)

C_OBJECTS = $(C_FILES:.c=.o)

default: cocoa_lib_stubs

cocoa_lib_stubs: $(OBJC_OBJECTS) $(C_OBJECTS)
	ocamlmklib -o OgamlCore_stubs $(OBJC_OBJECTS) $(C_OBJECTS)

%.o:%.m
	clang -c -o $@ $(OBJC_FLAGS) $<

%.o:%.c
	ocamlc -c -o $@ $(C_FLAGS) $<

.PHONY: cocoa_lib_stubs
