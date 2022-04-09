(

set -ue

CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=(put your team id here)

cd "$(dirname "$0")"

bash ../script/localization.sh

cmake .. -G Xcode \
    -DCMAKE_TOOLCHAIN_FILE=../deps/ios-cmake/ios.toolchain.cmake \
    -DENABLE_BITCODE=FALSE \
    -DPLATFORM=OS64COMBINED \
	-DCMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM=$CMAKE_XCODE_ATTRIBUTE_DEVELOPMENT_TEAM \
	-DLEVELDB_TCMALLOC=OFF \
	-DHAVE_CRC32C=OFF \
	-DHAVE_TCMALLOC=OFF \
	-DHAVE_CLANG_THREAD_SAFETY=OFF \
	-DMZ_LIBCOMP=OFF \
	-DLEVELDB_SNAPPY=OFF

bundle exec pod install

)
