OS_NAME =
CORE_JBUILD_FILE =
CLIBS_FILE =

UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
  OS_NAME = LINUX
  CORE_JBUILD_FILE = src/core/jbuild.x11
  CLIBS_FILE = config/flags.x11
endif
ifeq ($(UNAME), Darwin)
  OS_NAME = OSX
  CORE_JBUILD_FILE = src/core/jbuild.cocoa
  CLIBS_FILES = config/flags.cocoa
endif
ifeq ($(UNAME), windows32)
  OS_NAME = WIN
  CORE_JBUILD_FILE = src/core/jbuild.win
  CLIBS_FILES = config/flags.win
endif
 
