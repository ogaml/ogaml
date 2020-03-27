include config/configure.mk

DUNE_EXAMPLES_DIR = _build/default/examples

DOC_FILES = src/core/ogamlCore.mli\
						src/graphics/ogamlGraphics.mli\
						src/math/ogamlMath.mli\
						src/utils/ogamlUtils.mli\
						src/audio/ogamlAudio.mli

default: build

configure:
	cp $(CORE_DUNE_FILE) src/core/dune &&\
	cp $(CLIBS_FILE) c_libs.os &&\
	cp $(CFLAGS_FILE) c_flags.os

build: configure
	dune build @install --profile release

install:
	dune install

clean:
	dune clean &&\
	rm -rf html/ &&\
	rm -f src/core/dune &&\
	rm -f c_flags.os &&\
	rm -f c_libs.os &&\
	rm -f *.exe

uninstall:
	dune uninstall

tests:
	dune build @tests/runtest --profile release

examples:
	dune build @examples/all --profile release &&\
	mv $(DUNE_EXAMPLES_DIR)/*.exe .

doc:
	ocamlbuild -use-ocamlfind -use-menhir -cflags -rectypes -I src/doc -package unix,str mkdoc.native &&\
	./mkdoc.native $(DOC_FILES)

.PHONY: install uninstall doc tests examples
