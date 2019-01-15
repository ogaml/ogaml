include config/configure.mk

JBUILD_EXAMPLES_DIR = _build/default/examples

DOC_FILES = src/core/ogamlCore.mli\
						src/graphics/ogamlGraphics.mli\
						src/math/ogamlMath.mli\
						src/utils/ogamlUtils.mli\
						src/audio/ogamlAudio.mli

default: build

configure:
	cp $(CORE_JBUILD_FILE) src/core/jbuild &&\
	cp $(CLIBS_FILE) c_libs.os &&\
	cp $(CFLAGS_FILE) c_flags.os

build: configure
	jbuilder build @install

install:
	jbuilder install

clean:
	jbuilder clean &&\
	rm -rf html/ &&\
	rm -f src/core/jbuild &&\
	rm -f c_flags.os &&\
	rm -f c_libs.os &&\
	rm -f *.exe

uninstall:
	jbuilder uninstall

tests:
	jbuilder runtest tests

examples:
	jbuilder build examples/instancing.exe &&\
	jbuilder build examples/sprites.exe &&\
	jbuilder build examples/tut_idx.exe &&\
	jbuilder build examples/cube.exe &&\
	jbuilder build examples/models.exe &&\
	jbuilder build examples/ip.exe &&\
	jbuilder build examples/text.exe &&\
	jbuilder build examples/tut_tex.exe &&\
	jbuilder build examples/cursor.exe &&\
	jbuilder build examples/noise.exe &&\
	jbuilder build examples/tut01.exe &&\
	jbuilder build examples/vertexmaps.exe &&\
	jbuilder build examples/flat.exe &&\
	jbuilder build examples/shoot.exe &&\
	jbuilder build examples/tut02.exe &&\
	mv $(JBUILD_EXAMPLES_DIR)/*.exe .

doc:
	ocamlbuild -use-ocamlfind -use-menhir -cflags -rectypes -I src/doc -package unix,str mkdoc.native &&\
	./mkdoc.native $(DOC_FILES)

.PHONY: install uninstall doc tests examples
