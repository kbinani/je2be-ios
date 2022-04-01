cmake_minimum_required(VERSION 3.16)
project(je2be-ios LANGUAGES C CXX Swift)

set(LEVELDB_TCMALLOC OFF)

add_subdirectory(deps/je2be EXCLUDE_FROM_ALL)

set(je2be_ios_files
  src/AppDelegate.swift)

add_executable(je2be-ios MACOSX_BUNDLE ${je2be_ios_files})
set_target_properties(je2be-ios PROPERTIES
  BUNDLE True
  MACOSX_BUNDLE_GUI_IDENTIFIER com.github.kbinani.je2be-ios
  MACOSX_BUNDLE_BUNDLE_NAME je2be-ios
  MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
  MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
)
target_link_libraries(je2be-ios PRIVATE je2be)
set_property(TARGET je2be-ios PROPERTY XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++20")
set_property(TARGET je2be-ios PROPERTY XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "13.0")

set_property(TARGET leveldb PROPERTY XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "13.0")
set_property(TARGET minizip PROPERTY XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "13.0")

source_group(TREE ${CMAKE_CURRENT_LIST_DIR} FILES ${je2be_ios_files})
