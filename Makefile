OCAMLBUILD=ocamlbuild -use-ocamlfind -classic-display -j 4

OCAMLBUILD_DIR=$(shell ocamlc -where)/ocamlbuild

WINDOW_DIR = src/wm

XLIB_DIR   = $(WINDOW_DIR)/xlib

COCOA_DIR  = $(WINDOW_DIR)/cocoa

TEST_DIR   = src/test


window-test: clean
	$(OCAMLBUILD) -I $(WINDOW_DIR) $(TEST_DIR)/test_window.native


libwindow-nat-linux:
	$(OCAMLBUILD) -I $(XLIB_DIR) $(WINDOW_DIR)/ogamlWindow.cmxa


xlib-nat-test: clean xlib-nat
	$(OCAMLBUILD) -I $(XLIB_DIR) $(TEST_DIR)/xtest_simple.native

xlib-nat:
	$(OCAMLBUILD) $(XLIB_DIR)/xlib.cmxa


cocoa-nat-test: clean cocoa-nat
	$(OCAMLBUILD) -I $(COCOA_DIR) $(TEST_DIR)/ctest_simple.native

cocoa-nat:
	$(OCAMLBUILD) $(COCOA_DIR)/cocoa.cmxa


clean:
	$(OCAMLBUILD) -clean


