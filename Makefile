
# Directories 

SRC_DIR = src

WINDOW_DIR = $(SRC_DIR)/wm

XLIB_DIR = $(WINDOW_DIR)/xlib

COCOA_DIR = $(WINDOW_DIR)/cocoa

WM_DIRS = $(WINDOW_DIR), $(XLIB_DIR), $(COCOA_DIR), $(XLIB_DIR)/stubs, $(COCOA_DIR)/stubs

DIRS = $(SRC_DIR), $(SRC_DIR)/utils, $(SRC_DIR)/test, $(WM_DIRS)



# Compilation rules


