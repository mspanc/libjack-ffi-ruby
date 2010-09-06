#!/bin/bash
rm -rf libjack-ffi-ruby/

mkdir libjack-ffi-ruby/
mkdir libjack-ffi-ruby/DEBIAN
echo "Package: libjack-ffi-ruby
Version: `cat VERSION`
Section: base
Priority: optional
Architecture: all
Depends: ruby, libffi-ruby, libjack0
Maintainer: marcin@saepia.net
Description: Jack Audio Connection Kit bindings for ruby via FFI" > libjack-ffi-ruby/DEBIAN/control

cp -r lib/ VERSION GPL3-LICENSE libjack-ffi-ruby/
find libjack-ffi-ruby/ | grep '/\.' | xargs rm -rf

dpkg --build libjack-ffi-ruby ./
