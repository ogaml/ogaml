OS_NAME =
CORE_DUNE_FILE =
CLIBS_FILE =
CFLAGS_FILE =

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
  OS_NAME = LINUX
  CORE_DUNE_FILE = src/core/dune.x11
  CLIBS_FILE = config/c_libs.x11
  CFLAGS_FILE = config/c_flags.x11
endif
ifeq ($(UNAME), Darwin)
  OS_NAME = OSX
  CORE_DUNE_FILE = src/core/dune.cocoa
  CLIBS_FILE = config/c_libs.cocoa
  CFLAGS_FILE = config/c_flags.cocoa
endif
ifeq ($(UNAME), windows32)
  OS_NAME = WIN
  CORE_DUNE_FILE = src/core/dune.win
  CLIBS_FILE = config/c_libs.win
  CFLAGS_FILE = config/c_flags.win
endif
ifeq ($(UNAME), CYGWIN_NT-10.0)
  OS_NAME = WIN
  CORE_DUNE_FILE = src/core/dune.win
  CLIBS_FILE = config/c_libs.win
  CFLAGS_FILE = config/c_flags.win
endif
