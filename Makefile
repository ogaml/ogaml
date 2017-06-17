include config/configure.mk

DOC_FILES = src/core/ogamlCore.mli\
						src/graphics/ogamlGraphics.mli\
						src/math/ogamlMath.mli\
						src/utils/ogamlUtils.mli\
						src/audio/ogamlAudio.mli

default: build

configure:
	cp $(CORE_JBUILD_FILE) src/core/jbuild;
	cp $(CLIBS_FILE) flags.os

build: configure
	jbuilder build

install:
	jbuilder install

clean:
	jbuilder clean;
	rm -rf html/;
	rm -f src/core/jbuild;
	rm -f flags.os

uninstall:
	jbuilder uninstall

tests:
	echo 'Not yet implemented'

examples:
	echo 'Not yet implemented'

doc:
	ocamlbuild -use-ocamlfind -use-menhir -cflags -rectypes -I src/doc -package unix,str mkdoc.native;\
	./mkdoc.native $(DOC_FILES)

.PHONY: install uninstall doc tests examples
