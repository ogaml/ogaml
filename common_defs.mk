
# OS-dependant constants

OS_WIN_STUBS = 
OS_WIN_STUBS_DIR = 
OS_WIN_STUBS_TEST = 

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
  OS_WIN_STUBS += xlib_stubs
  OS_WIN_STUBS_DIR += xlib/
  OS_WIN_STUBS_TEST += xtest_simple
endif
ifeq ($(UNAME), Darwin)
  OS_WIN_STUBS += cocoa_stubs
  OS_WIN_STUBS_DIR += cocoa/
  OS_WIN_STUBS_TEST += ctest_simple
endif

# Compilers

OCAMLDEP = ocamldep

OCAMLC = ocamlc 

OCAMLOPT = ocamlopt

OCAMLMKLIB = ocamlmklib



# Constants
  # Extensions used for cleaning
EXTENSIONS = *.cmi *.cmo *.out *.cma *.cmxa *.o *.a *.cmx *.so *.native *.out *.byte *.d

INCLUDE_DIRS = 

NATIVEFLAGS = 

BYTEFLAGS = 

STUBS_DIR = stubs


# Commands

PPCOMMAND = cppo

DEPCOMMAND = $(OCAMLDEP) -pp "$(PPCOMMAND)" $(INCLUDE_DIRS) 


# Suffixes

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .a .mllib .clib



