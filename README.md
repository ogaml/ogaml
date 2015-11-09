# ogaml

#### Ocaml multimedia library

[![Build Status](https://travis-ci.org/ogaml/ogaml.svg?branch=master)](https://travis-ci.org/ogaml/ogaml)

This is only in early stages...

* Current dependencies : 

    * cppo (preprocessor)

    * x11 (Linux only)

    * OpenGL libraries

* This project provides 3 modules (for now) : 

    * OgamlMath - provides mathematical functions and structures such
      as vectors, matrices, polygons. This module is particularly helpful
      for 3D rendering (projection matrices, polygon generation, etc...).

    * OgamlGL (depends on OgamlMath) - provides type-safe, modular and 
      high-level bindings for most openGL functions. Please note that the 
      aim of this module is not to provide thin bindings and some features 
      may be missing due to abstraction.

    * OgamlWindow (depends on OgamlGL) - provides multi-platform window
      and context creation, as well as event manipulation.


