#!/bin/bash
rm -rf libjack-ffi-ruby1.8/

mkdir libjack-ffi-ruby1.8/
mkdir libjack-ffi-ruby1.8/DEBIAN
echo "Package: libjack-ffi-ruby1.8
Version: `cat VERSION`
Section: base
Priority: optional
Architecture: all
Depends: ruby, libffi-ruby, libjack0
Maintainer: marcin@saepia.net
Description: Jack Audio Connection Kit bindings for ruby via FFI" > libjack-ffi-ruby1.8/DEBIAN/control

mkdir -p libjack-ffi-ruby1.8/usr/lib/ruby/1.8/
cp -r lib/* libjack-ffi-ruby1.8/usr/lib/ruby/1.8/
find libjack-ffi-ruby1.8/ | grep '/\.' | xargs rm -rf

dpkg --build libjack-ffi-ruby1.8 ./
rm -rf libjack-ffi-ruby1.8/

rm -rf libjack-ffi-ruby/

mkdir libjack-ffi-ruby/
mkdir libjack-ffi-ruby/DEBIAN
echo "Package: libjack-ffi-ruby
Version: `cat VERSION`
Section: base
Priority: optional
Architecture: all
Depends: libjack-ffi-ruby1.8
Maintainer: marcin@saepia.net
Description: Jack Audio Connection Kit bindings for ruby via FFI" > libjack-ffi-ruby/DEBIAN/control

find libjack-ffi-ruby/ | grep '/\.' | xargs rm -rf

dpkg --build libjack-ffi-ruby ./
rm -rf libjack-ffi-ruby/


