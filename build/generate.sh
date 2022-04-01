(

CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=(put your team id here)

cd "$(dirname "$0")"
cmake .. -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=../deps/ios-cmake/ios.toolchain.cmake \
    -DPLATFORM=OS64 \
	-DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=$CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM \
	-DHAVE_CRC32C=OFF \
	-DHAVE_TCMALLOC=OFF \
	-DHAVE_CLANG_THREAD_SAFETY=OFF

)
