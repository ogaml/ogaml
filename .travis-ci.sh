#!/bin/bash

OPAM_DEPEND="menhir jbuilder"

sh -e /etc/init.d/xvfb start

case "$OCAML_VERSION" in
  3.12.1) ppa=avsm/ocaml312+opam12 ;;
  4.00.1) ppa=avsm/ocaml40+opam12 ;;
  4.01.0) ppa=avsm/ocaml41+opam12 ;;
  4.02.0) ppa=avsm/ocaml42+opam12 ;;
  4.02.1) ppa=avsm/ocaml42+opam12 ;; 
  *) echo Unknown OCaml version $OCAML_VERSION; exit 1 ;;
esac

sudo add-apt-repository -y ppa:$ppa
sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers camlp4-extra opam

export OPAMYES=1
opam init

eval `opam config env`
opam install ${OPAM_DEPEND}

make tests
make install
make clean
make examples
make uninstall
glxinfo
