
# OS-dependant constants

OS_NAME = 
OS_WIN_STUBS =
OS_WIN_STUBS_DIR =
OS_WIN_STUBS_TEST =
PP_DEFINE = 

UNAME := $(shell uname)

COMPATIBILITY_MODE = True

ifeq ($(UNAME), Linux)
  OS_NAME = LINUX
  ifeq ($(COMPATIBILITY_MODE), True)
    PP_DEFINE = __OSX__
    OS_WIN_STUBS = cocoa_stubs
    OS_WIN_STUBS_DIR = cocoa/
    OS_WIN_STUBS_TEST = ctest_simple
  else 
    PP_DEFINE = __LINUX__
    OS_WIN_STUBS = xlib_stubs
    OS_WIN_STUBS_DIR = xlib/
    OS_WIN_STUBS_TEST = xtest_glcube
  endif
endif
ifeq ($(UNAME), Darwin)
  PP_DEFINE = __OSX__
  OS_NAME = OSX
  OS_WIN_STUBS = cocoa_stubs
  OS_WIN_STUBS_DIR = cocoa/
  OS_WIN_STUBS_TEST = ctest_simple
endif

# Compilers

OCAMLDEP = ocamldep

OCAMLC = ocamlc

OCAMLOPT = ocamlopt

OCAMLMKLIB = ocamlmklib

CLANG = clang

OCAMLFIND = ocamlfind



# Constants
  # Extensions used for cleaning
EXTENSIONS = *.cmi *.cmo *.out *.cma *.cmxa *.o *.a *.cmx *.so *.native *.out *.byte *.d

INCLUDE_DIRS =

NATIVEFLAGS =

BYTEFLAGS =

STUBS_DIR = stubs

OCAML_DIR = $(shell $(OCAMLC) -where)
  #ocaml flags for compiling c, because ocamlc doesn't recognize .m files...
CCOMPIL_FLAGS = -Wall -D_FILE_OFFSET_BITS=64 -D_REENTRANT -fPIC -I '$(OCAML_DIR)'


# Commands

PPCOMMAND = cppo -D '$(strip $(PP_DEFINE))'

DEPCOMMAND = $(OCAMLDEP) -pp "$(PPCOMMAND)" $(INCLUDE_DIRS)


# Suffixes

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .a .mllib .clib .m

