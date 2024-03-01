This README file contains information on the contents of the meta-adacore layer.

## Dependencies

* URI: https://git.openembedded.org/openembedded-core
    * branch: master
    * revision: HEAD
* URI: https://git.openembedded.org/bitbake
    * branch: master
    * revision: HEAD

## Build/Install

**Add layers**
```sh
$ bitbake-layers add-layer meta-adacore
```

# Usage

**Choose initial compiler to build YP version**
```Bitbake
# Set recipe to use for compilation of
# Yocto project cross compilers.
PREFERRED_PROVIDER_virtual/gnat1 = "alire-gnat-native"
PREFERRED_PROVIDER_virtual/gprbuild1` = "adacore-gnat-native"
```
