#!/bin/bash
clear

# 1.) Make sure build directory exists
if [ -d "out/build" ]; then
	echo "build directory does not exist"
else
	mkdir out
	mkdir out/build
fi

# 2.) cd into build and run cmake
cd out/build
cmake \
	-DCMAKE_PREFIX_PATH="C:\Users\kchah\Code\Libraries\libtorch" \
	../..
#cmake --build . --config Release

# For non VS build systems
# cmake .. -DCMAKE_TOOLCHAIN_FILE=D:/code/libraries/vcpkg/scripts/buildsystems/vcpkg.cmake
