
# OS-dependant constants

OS_NAME =
PP_DEFINE =
OS_WIN_LIB =
GLOBAL_OBJCOPTS =
GLOBAL_CLIBS =

UNAME := $(shell uname)

COMPATIBILITY_MODE = False

ifeq ($(UNAME), Linux)
  OS_NAME = LINUX
  ifeq ($(COMPATIBILITY_MODE), True)
    PP_DEFINE = __OSX__
    OS_WIN_LIB = cocoa
    GLOBAL_OBJCOPTS = $(shell gnustep-config --objc-flags)
    GLOBAL_CLIBS = $(shell gnustep-config --gui-libs)
  else
    PP_DEFINE = __LINUX__
    OS_WIN_LIB = x11
    GLOBAL_OBJCOPTS =
    GLOBAL_CLIBS = -lX11 -lGL -lX11-xcb -lxcb
  endif
endif
ifeq ($(UNAME), Darwin)
  PP_DEFINE = __OSX__
  OS_NAME = OSX
  OS_WIN_LIB = cocoa
  GLOBAL_OBJCOPTS = -fconstant-string-class=NSConstantString
  GLOBAL_CLIBS = -framework Foundation -framework Cocoa -framework Carbon -lobjc -framework openGL
endif


# Compilers

OCAMLDEP = ocamldep

OCAMLC = ocamlc

OCAMLOPT = ocamlopt

OCAMLMKLIB = ocamlmklib

CLANG = clang

OCAMLFIND = ocamlfind

MENHIR = menhir

LEX = ocamllex



# Constants
  # Extensions used for cleaning
CLEAN_EXTENSIONS = *.cmi *.cmo *.out *.cma *.cmxa *.o *.a *.cmx *.so *.native *.out *.byte *.d

STUBS_DIR = stubs

OCAML_DIR = $(shell $(OCAMLC) -where)
  #ocaml flags for compiling c, because ocamlc doesn't recognize .m files...
OCAML_C_FLAGS = -Wall -D_FILE_OFFSET_BITS=64 -D_REENTRANT -fPIC -I '$(OCAML_DIR)'


# Commands

PPCOMMAND = cppo -D '$(strip $(PP_DEFINE))'

DEPCOMMAND = $(OCAMLDEP) -pp "$(PPCOMMAND)" $(INCLUDE_DIRS)


# Suffixes

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .a .mllib .clib .m
