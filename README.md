# About 

Demo repository exloring how to automatically provide custom bash functions to 

- all make recipes   

- inline shell calls (`$(shell ...)`)

## What is it good for ?

When developing larger Makefile's you will recognize

- duplicated bash code within make your recipes

- large bash recipes across many lines (possible thanks to [make directive `.ONESHELL:`](https://www.gnu.org/software/make/manual/html_node/One-Shell.html))

- longer bash recipe blocks will look very confusing due to [the `$` escaping issue](https://stackoverflow.com/a/2382810/1554103)

Would'nt it be nice to out source such bash code in separate shell scripts for 

- easier maintenance

  Makefile just consist of shorter recipes just calling your bash functions

- testing 

  Your bash can be hardened by tests. 
  
  There exist a bunch of mature shell testing frameworks like https://github.com/kward/shunit2 or [bats](https://github.com/bats-core/bats-core)

- reusable code

  Your bash functions can now be reused in other _slightly different_ projects.

? 

I think the answer is a clear __Y.E.S.__ !

This repo contains some working examples implementing automatic configurable provisioning of custom bash libraries in Makefile's. 

Depending on your needs you can choose wich variant works best for you.

## Is it used somewhere ? 

I use some of the ideas implemented here in a generic make framework called [pnpmkambrium](https://github.com/lgersman/pnpmkambrium) by myself.

[pnpmkambrium](https://github.com/lgersman/pnpmkambrium) goes far beyond the technique described here - it provides 

- a generic Meta Makefile for building/uploading 

  - docker images

  - npm packages

  - wordpress plugins/themes

  - ...

  out of the box

- customizable by `.env` and `.secret` files. 

  In most cases you don't need to extend/customize the Makefile's

  _But you can extend it with your own Bash functions and Make targets/rules._

You may also have a look at my [Makefile recipes in various languages](https://github.com/lgersman/make-recipes-in-different-scripting-languages-demo) GitHub repo showing how to use almost any scripting language (instead of bash) to implement Makefile recipes

## Prerequisites

- GNU make

- Bash

## Prior art

- https://github.com/nclsgd/makebashwrapper

