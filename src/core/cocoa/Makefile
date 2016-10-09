include ../../../common_defs.mk

# ML constants

ML_SOURCES = cocoa.ml

ML_OBJS = $(ML_SOURCES:.ml=.cmo)

ML_NATS = $(ML_SOURCES:.ml=.cmx)

ML_INTERFACES = $(ML_SOURCES:.ml=.mli)

ML_CMIS = $(ML_INTERFACES:.mli=.cmi)


# Compilation

default: $(ML_CMIS) $(ML_OBJS) $(ML_NATS)

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

