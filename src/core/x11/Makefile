include ../../../common_defs.mk

# ML constants

ML_SOURCES = x11.ml

ML_OBJS = $(ML_SOURCES:.ml=.cmo)

ML_NATS = $(ML_SOURCES:.ml=.cmx)


# Compilation

default: depend $(ML_OBJS) $(ML_NATS)

include .depend

%.cmi:%.mli
	$(OCAMLC_CMD) -c -o $@ $<

%.cmx:%.ml $(wildcard %.cmi)
	$(OCAMLOPT_CMD) -c -o $@ -for-pack $(CORE_PACK) $<

%.cmo:%.ml $(wildcard %.cmi)
	$(OCAMLC_CMD) -c -o $@ -for-pack $(CORE_PACK) $<


# Cleaning

clean:
	rm -f $(CLEAN_EXTENSIONS)


# Dependencies

depend:.depend

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend

.PHONY: .depend

