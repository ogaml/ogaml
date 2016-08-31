
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
	# Without the following line, I don't get the warnings, but then it fails
	# when compiling the examples...
  GLOBAL_CLIBS = -framework Foundation -framework Cocoa -framework Carbon -lobjc -framework openGL
	# GLOBAL_CLIBS =
endif
ifeq ($(UNAME), windows32)
  PP_DEFINE = __WIN__
  OS_NAME = WIN
  OS_WIN_LIB = windows
  GLOBAL_OBJCOPTS = 
  GLOBAL_CLIBS =
endif
  

# Compilers

OCAMLDEP = ocamldep

OCAMLC = ocamlc

OCAMLOPT = ocamlopt

OCAMLMKLIB = ocamlmklib

CLANG = clang

OCAMLFIND = 

MENHIR = ocamlyacc

LEX = ocamllex



# Constants
  # Extensions used for cleaning
CLEAN_EXTENSIONS = *.cmi *.cmo *.out *.cma *.cmxa *.o *.a *.cmx *.so *.native *.out *.byte *.d

STUBS_DIR = stubs

OCAML_DIR = $(shell $(OCAMLC) -where)
  #ocaml flags for compiling c, because ocamlc doesn't recognize .m files...
OCAML_C_FLAGS = -Wall -D_FILE_OFFSET_BITS=64 -D_REENTRANT -fPIC -I '$(OCAML_DIR)'


# Built libraries
CORE_LIB = ogamlCore

GRAPHICS_LIB = ogamlGraphics

MATH_LIB = ogamlMath

UTILS_LIB = ogamlUtils

CORE_PACK = OgamlCore

GRAPHICS_PACK = OgamlGraphics

MATH_PACK = OgamlMath

UTILS_PACK = OgamlUtils


# Commands

PPCOMMAND = -pp "cppo -D \"$(strip $(PP_DEFINE))\""

DEPCOMMAND = $(OCAMLDEP) $(PPCOMMAND) $(INCLUDE_DIRS)

OCAMLOPT_CMD = $(OCAMLOPT) $(PPCOMMAND)

OCAMLC_CMD = $(OCAMLC) $(PPCOMMAND)


# Suffixes

.SUFFIXES: .ml .mli .cmo .cmi .cmx .c .o .a .mllib .clib .m
