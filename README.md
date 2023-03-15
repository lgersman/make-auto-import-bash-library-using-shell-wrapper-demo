# About 

Demo repository exloring how to automatically provide custom bash functions/symbols to 

- make recipes   

- make shell function calls (i.e. `$(shell ...)`)

## What is it good for ?

When developing larger Makefile's you will recognize

- duplicated bash code within make your recipes

- large bash recipes across many lines (possible thanks to make directive [`.ONESHELL`](https://www.gnu.org/software/make/manual/html_node/One-Shell.html))

- longer bash recipe blocks will look very confusing due to the [`$` escaping issue](https://stackoverflow.com/a/2382810/1554103)

Would'nt it be nice to out source such bash code in separate shell script libraries ?  

- easier maintenance

  Makefiles just consist of short recipes just calling your bash functions

  Makefile
  ```make
  deploy: build
    github::release $(GIT_TAG) $(GITHUB_USER) $(GITHUB_TOKEN)
  ```

  your Bash library
  ```bash
  function github::release() {
    ...
  }
  export -f github::release
  ```

- testing 

  Your bash scripts can be hardened by tests. 
  
  There exist a bunch of mature shell testing frameworks like https://github.com/kward/shunit2 or [bats](https://github.com/bats-core/bats-core) for testing bash code

- reusable code

  Your bash functions can now be reused in other _slightly different_ projects.

I think the answer is a clear : __Y.E.S.__ !

---

This repo contains some working examples implementing automatic configurable provisioning of custom bash libraries in Makefile's. 

Depending on your needs you can choose wich variant works best for you.

- [./make-bash-init-script-simply-but-partly-broken/](./make-bash-init-script-simply-but-partly-broken/) 

  Contains a very simplistic effort utilizing Bash's `--rcfile` option to inject your bash functions to the Makefile. It has a few caveats but may be okay for smaller Makefiles.

- [./make-bash-library-injection-modular-take/](./make-bash-library-injection-modular-take/) ist the __GOLD__ solution without any caveats. This solution requires a bit more Make/Bash bootstrapping code but fit's every case

So if you don't know which one to use ... head over to the __GOLD__ solution - it works in every case.

---

## Is it used somewhere ? 

I use some of the ideas implemented here in a generic make framework called [pnpmkambrium](https://github.com/lgersman/pnpmkambrium) by myself.

[pnpmkambrium](https://github.com/lgersman/pnpmkambrium) goes far beyond the technique described here - it provides 

- a generic Meta Makefile maintaining monorepos for building/uploading 

  - docker images

  - npm packages

  - wordpress plugins/themes

  - ...

  out of the box

- customizable by `.env` and `.secret` files. 

  In most cases you don't need to write custom Makefile's - just provide `.env` files (for non-sensitive data) and `.secrets` files (for sensitive data like credentials). 

- You can even extend it with your own Bash functions and Make targets/rules.

You may also have a look at my [Makefile recipes in various languages](https://github.com/lgersman/make-recipes-in-different-scripting-languages-demo) GitHub repo showing how to use almost any scripting language (instead of bash) to implement Makefile recipes

## Prerequisites

- GNU make

- Bash

## Prior art

- https://github.com/nclsgd/makebashwrapper

