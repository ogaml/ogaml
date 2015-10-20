
# OS-dependant constants

OS_WIN_LIB = 
OS_WIN_STUBS = 
OS_WIN_STUBS_DIR = 

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
  OS_WIN_LIB += -lX11
  OS_WIN_STUBS += -lxlib_stubs
  OS_WIN_STUBS_DIR += xlib/
endif
ifeq ($(UNAME), Darwin)
endif

# Compilers

OCAMLDEP = ocamldep

OCAMLC = ocamlc 

OCAMLOPT = ocamlopt

OCAMLMKLIB = ocamlmklib



# Constants

EXTENSIONS = *.cmi *.cmo *.out *.cma *.cmxa *.o *.a *.cmx *.so

INCLUDE_DIRS = 

NATIVEFLAGS = 

BYTEFLAGS = 

STUBS_DIR = stubs


# Commands

PPCOMMAND = cppo

DEPCOMMAND = $(OCAMLDEP) -pp "$(PPCOMMAND)" $(INCLUDE_DIRS) 


# Suffixes

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .a .mllib .clib



