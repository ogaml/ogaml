# OGAML

#### OCaml Game And Multimedia Library

[![Build Status](https://travis-ci.org/ogaml/ogaml.svg?branch=master)](https://travis-ci.org/ogaml/ogaml)

DISCLAIMER : This library is only in early stages and some features will probably
change or be removed.

## Presentation :

OGAML is a fast and cross-platform multimedia library for OCaml. It provides
the following modules :

  * OgamlMath - provides mathematical functions and structures such as 
    vectors, matrices, quaternion and polygons. This module is particularly
    helpful for 3D rendering (projection matrices, polygon generation, etc...).

  * OgamlCore - provides high-level window and event management and encapsulates 
    the low-level bindings to the various window libraries (Xlib, Cocoa, etc...). 
    Also provides various functionalities such as a logging system and manipulation 
    of UTF8-encoded strings.

  * OgamlGraphics - provides 2D and 3D rendering functions. The aim of this 
    module is to provide high-level, type-safe and modular bindings for most
    OpenGL functions, while hiding all the error-prone OpenGL API. 
    A rule of thumb for this module is "all OpenGL errors or undefined
    behaviors should be catched by the type system (at best) or raise an exception".
    OpenGL state changes are optimised (no redundant changes) and most of the 
    state mutability is hidden behind wrappers. 

  * OgamlUtils (WIP) - provides several useful functions and data structures for 
    game development, such as interpolators, graphs or UTF8-encoded strings 
    (still in OgamlCore for now).
    
Our ultimate goal is to add access to music, network, and to implement more 
helpers to make games (like physics, lighting, etc...).


## Building and installing OGAML (OSX/Linux only) : 
  
You will need the following dependancies : 

  * cppo (preprocessor)

  * x11 (Linux only)

  * OpenGL libraries

Then `make install` should do the trick. You can test it on some examples 
`make examples` or on Travis' tests `make tests`.

