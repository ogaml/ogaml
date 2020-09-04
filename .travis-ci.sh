#!/bin/bash

OPAM_DEPEND="menhir dune"

sudo apt-get update -qq
sudo apt-get install -qq ocaml ocaml-native-compilers opam
sudo apt-get -qq --force-yes install libgl1-mesa-dev libgl1-mesa-glx mesa-common-dev libglapi-mesa libgbm1 libgl1-mesa-dri libxatracker-dev
sudo apt-get -qq --force-yes install libglew-dev freeglut3-dev libxi-dev libxmu-dev xserver-xorg-video-dummy xpra xorg-dev opencl-headers libgl1-mesa-dev
sudo apt-get -qq --force-yes install libxcursor-dev libpulse-dev libxinerama-dev libxrandr-dev libx11-xcb-dev libopenal-dev libxv-dev libasound2-dev libudev-dev mesa-utils libgl1-mesa-glx

export OPAMYES=1
opam init --compiler=$OCAML_VERSION

eval `opam config env`
opam install ${OPAM_DEPEND}

make
make install
xvfb-run --auto-servernum --server-num=1 make tests
xvfb-run --auto-servernum --server-num=1 make examples
make uninstall
make clean
xvfb-run --auto-servernum --server-num=1 glxinfo
