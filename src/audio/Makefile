include ../../common_defs.mk

# Override

INCLUDE_DIRS = -I ../math/ -I ../utils/

AUDIO_STUBS = device_stubs.c context_stubs.c audio_stubs.c listener_stubs.c buffer_stubs.c source_stubs.c

STUBS_SRC = $(addprefix $(STUBS_DIR)/, $(AUDIO_STUBS))

STUBS_TARGET = $(STUBS_SRC:.c=.o)

STUBS_OBJS = $(AUDIO_STUBS:.c=.o)

MLSOURCES = AL.ml AudioContext.ml SoundBuffer.ml AudioStream.ml AudioSource.ml

MLINTERFACES = 

MLOBJS = $(MLSOURCES:.ml=.cmo)

MLNATOBJS = $(MLSOURCES:.ml=.cmx)

MLCMISALONE = $(MLINTERFACES:.mli=.cmi)

MLCMIS = $(MLCMISALONE) $(PARSER_FILES:.mly=.cmi) $(LEXER_FILES:.mll=.cmi) $(MLSOURCES:.ml=.cmi)

COPTS = -Wno-unused-function -Wno-unused-variable -Wno-misleading-indentation

CMA_DEPS = ../math/$(MATH_LIB).cma ../utils/$(UTILS_LIB).cma
CMXA_DEPS = ../math/$(MATH_LIB).cmxa ../utils/$(UTILS_LIB).cmxa


# Lib compilation 

ifeq ($(OS_NAME), WIN)
    LIB_CMD = \
        $(OCAMLFIND) $(OCAMLC_CMD) -a -o $(AUDIO_LIB).cma $(AUDIO_LIB).cmo\
            -cclib -l$(AUDIO_LIB) -cclib "$(GLOBAL_CLIBS)" &&\
        $(OCAMLFIND) $(OCAMLOPT_CMD) -a -o $(AUDIO_LIB).cmxa $(AUDIO_LIB).cmx\
            -cclib -l$(AUDIO_LIB) -cclib "$(GLOBAL_CLIBS)"&&\
        lib -out:lib$(AUDIO_LIB).lib $(STUBS_OBJS)
else
    LIB_CMD =\
        $(OCAMLFIND) $(OCAMLMKLIB) -o $(AUDIO_LIB) $(STUBS_OBJS) $(AUDIO_LIB).cmo $(AUDIO_LIB).cmx\
            $(MLOBJS) $(MLNATOBJS) $(GLOBAL_CLIBS)
endif


# Compilation

default: audio_lib

audio_lib: $(STUBS_TARGET) $(MLCMIS) $(MLOBJS) $(MLNATOBJS) $(AUDIO_LIB).cmi
	$(OCAMLFIND) $(OCAMLC_CMD) -pack -o $(AUDIO_LIB).cmo $(MLCMISALONE) $(MLOBJS) &&\
	$(OCAMLFIND) $(OCAMLOPT_CMD) -pack -o $(AUDIO_LIB).cmx $(MLCMISALONE) $(MLNATOBJS) &&\
	$(LIB_CMD)

%.cma:%.cmo
	$(OCAMLFIND) $(OCAMLC_CMD) -a -o $@ $(INCLUDE_DIRS) $<

%.cmxa:%.cmx
	$(OCAMLFIND) $(OCAMLOPT_CMD) -a -o $@ $(INCLUDE_DIRS) $<

%.cmi:%.mli
	$(OCAMLFIND) $(OCAMLC_CMD) -for-pack $(AUDIO_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.cmi:%.ml
	$(OCAMLFIND) $(OCAMLC_CMD) -for-pack $(AUDIO_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.cmx:%.ml $(wildcard %.cmi)
	$(OCAMLFIND) $(OCAMLOPT_CMD) -for-pack $(AUDIO_PACK) $(INCLUDE_DIRS) $(CMXA_DEPS) -c $< -o $@
 
%.cmo:%.ml $(wildcard %.mli)
	$(OCAMLFIND) $(OCAMLC_CMD) -for-pack $(AUDIO_PACK) $(INCLUDE_DIRS) $(CMA_DEPS) -c $< -o $@

%.o:%.c
	$(OCAMLFIND) $(OCAMLC_CMD) -o ./$(notdir $@) -c $< -ccopt "$(COPTS)" -cclib "$(GLOBAL_CLIBS)"


# Cleaning

clean:
	rm -f $(CLEAN_EXTENSIONS) &\
	rm -f .depend


# Dependencies

depend:.depend

.depend:
	$(DEPCOMMAND) *.ml *.mli > .depend


.PHONY: .depend
