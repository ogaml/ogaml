# OGaml

#### OCaml Game And Multimedia Library

[![Build Status](https://travis-ci.org/ogaml/ogaml.svg?branch=master)](https://travis-ci.org/ogaml/ogaml)

DISCLAIMER: This library is only in early stages and some features will probably
change or be removed.

NOTE: When developping OGaml, we try to enforce the absence of undefined 
behaviours. We also try to hide most low-level functions, even though there are
cases where we need to expose them (such as texture binding functions). If you
find an error that is not catched, an undefined behaviour, or a low-level
function that could have been hidden, please open an issue :-)

## Presentation:

OGaml is a fast and cross-platform multimedia library for OCaml, currently supporting
Windows, OSX and Linux (X11 only). It provides the following modules:

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
    game development, such as interpolators, graphs or UTF8-encoded strings.

  * OgamlAudio (WIP) - provides high-level wrappers around OpenAL for sounds
    and music. This module lets you safely control audio sources and contexts,
    play short sounds or long musics. It follows the same philosophy as 
    OgamlGraphics, that is, there should be no undefined behaviour or 
    non-catched error.
    
You can find some examples in the corresponding directory as well as on the 
documentation http://ogaml.github.io.

Upcoming features:

  * Batch drawing optimisation

  * More image and textures types
    
Our ultimate goal is to add networking wrappers, and to implement more 
helpers to make games (like physics, lighting, etc...).

## Why use OGaml (rather than raw OpenGL for example)?

OGaml is safe and easy to use: 

  * The functions are high-level and the API tries to be as functional as 
  possible. This should help to avoid bugs due to mutable values, pointers, or
  untyped enumerations.

  * OGaml provides everything necessary to do 2D/3D rendering from window 
  management to text rendering and vertex arrays.

  * OpenGL structures such as vertex arrays are hidden behind functional and
  easy to understand types that are easier to manipulate. Structures such as
  vertex buffers and samplers are hidden and don't have to be allocated 
  manually.

  * OpenGL enumerations (GLenum) are binded to variant types (rather then simple
  integers) to provide more type safety. You should not be able to pass invalid
  enumerations to OpenGL functions.

  * The OpenGL state is hidden and does not have to be modified manually (no
  `glEnable`). Everything is done via function parameters such that calling
  the same function twice with the same parameters should give the same 
  result (independently of what has been executed between the two calls).
  Moreover, all state changes are optimised such that no redundant changes are
  performed.

  * OGaml should detect any error or undefined behavior and at least raise an
  exception before it happens. This means that you don't need to call 
  `glGetError` (which is quite costly). 

OGaml provides advanced functionalities:

  * The module VertexArray provides a high-level and easy to use wrapper around
  OpenGL's vertex arrays. You can easily create a vertex array that contains
  common data such as positions, colors or UV coordinates; or you can define
  a new custom type of vertices to store any kind of data in a vertex array.

  * The module Shape provides easy manipulation of 2D shapes such as rectangles,
  circles or regular polygons. The module Sprite provides functions to render
  2D sprites and apply various transformations to them.

  * It is easy to render 2D text of any color and size using the module Text. 
  It also provides a way to add effects (such as moving letters, changing color,
  etc...) in a modular and functional way. 

  * If you want to make an AAA-looking game with dozens of post-processing 
  effects, the modules Framebuffer and Renderbuffer provide a high-level and
  safe way to create off-screen render targets. 
  All the rendering functions make use of first-class modules to provide some
  polymorphism. This allows you to easily switch between rendering to a window
  or to a framebuffer. 

## Building and installing OGaml:

Thanks to Jbuilder, it is now easier than ever to compile and install OGaml.
You will need the following dependencies, depending on your OS:

  * Jbuilder (available via opam)

  * OpenGL libraries (3.0 minimum)

  * x11 (Linux)

  * OpenGL headers and libraries - opengl32.dll (Windows)

  * GLEW headers and libraries - glew32.dll (Windows)

  * gdi32.dll and user32.dll (Windows, whould be available by default)

  * Microsoft Windows SDK (Windows)

Then the usual spell, `make && make install` will take care of the rest.
You can test it on some examples `make examples` or on Travis' tests `make tests`.

## Redistributing OGaml executables

OGaml executables are almost standalone !

If you want to redistribute an executable, you only have to provide all the
required assets (shader sources, textures, fonts, ...), and GLEW's DLL (glew32.dll)
if you're redistributing a Windows executable. That's as simple as that !
