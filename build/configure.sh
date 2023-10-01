(

set -ue

CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=XM695N4A7T

cd "$(dirname "$0")"

cmake .. -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=../deps/ios-cmake/ios.toolchain.cmake \
    -DENABLE_BITCODE=FALSE \
    -DPLATFORM=OS64COMBINED \
    -DDEPLOYMENT_TARGET=15.0 \
    -DENABLE_ARC=ON \
    -DENABLE_VISIBILITY=OFF \
    -DENABLE_STRICT_TRY_COMPILE=OFF \
    -DNAMED_LANGUAGE_SUPPORT=ON \
	-DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=$CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM \
	-DCMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
	-DLEVELDB_TCMALLOC=OFF \
	-DHAVE_CRC32C=OFF \
	-DHAVE_TCMALLOC=OFF \
	-DHAVE_CLANG_THREAD_SAFETY=OFF \
	-DMZ_LIBCOMP=OFF \
	-DLEVELDB_SNAPPY=OFF

bundle install
bundle exec pod install

)
