OCAMLBUILD=ocamlbuild -use-ocamlfind -classic-display -j 4

OCAMLBUILD_DIR=$(shell ocamlc -where)/ocamlbuild

XLIB_DIR=src/wm/xlib

COCOA_DIR=src/wm/cocoa

TEST_DIR=src/test


xlib-nat-test: xlib-nat
	$(OCAMLBUILD) -I $(XLIB_DIR) $(TEST_DIR)/xtest_simple.native

xlib-byte-test: xlib-byte
	$(OCAMLBUILD) -I $(XLIB_DIR) $(TEST_DIR)/xtest_simple.byte

xlib: xlib-nat xlib-byte

xlib-nat:
	$(OCAMLBUILD) $(XLIB_DIR)/xlib.cmxa

xlib-byte:
	$(OCAMLBUILD) $(XLIB_DIR)/xlib.cma


cocoa-nat-test: cocoa-nat
	$(OCAMLBUILD) -I $(COCOA_DIR) $(TEST_DIR)/ctest_simple.native

cocoa-byte-test: cocoa-byte
	$(OCAMLBUILD) -I $(COCOA_DIR) $(TEST_DIR)/ctest_simple.byte

cocoa: cocoa-nat cocoa-byte

cocoa-nat:
	$(OCAMLBUILD) $(COCOA_DIR)/cocoa.cmxa

cocoa-byte:
	$(OCAMLBUILD) $(COCOA_DIR)/cocoa.cma


clean:
	$(OCAMLBUILD) -clean


