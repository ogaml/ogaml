include ../../../common_defs.mk

# ML constants

ML_SOURCES = x11.ml

ML_OBJS = $(ML_SOURCES:.ml=.cmo)

ML_NATS = $(ML_SOURCES:.ml=.cmx)


# Compilation

default: .depend $(ML_OBJS) $(ML_NATS)

%.cmi:%.mli
	$(OCAMLC) -c -o $@ $<

%.cmx:%.ml
	$(OCAMLOPT) -c -o $@ -for-pack OgamlCore $<

%.cmo:%.ml
	$(OCAMLC) -c -o $@ -for-pack OgamlCore $<


# Cleaning

clean:
	rm -rf $(CLEAN_EXTENSIONS)


# Dependencies

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

include .depend

.PHONY: .depend

