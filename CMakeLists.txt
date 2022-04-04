cmake_minimum_required(VERSION 3.16)
project(je2be-ios LANGUAGES C CXX Swift)

add_subdirectory(deps/je2be EXCLUDE_FROM_ALL)

set(je2be_ios_files
  src/AppDelegate.swift
  src/ModeSelectViewController.swift
  src/ChooseInputViewController.swift
  src/Localization.swift
  src/Converter.h
  src/ConvertJavaToBedrock.mm
  src/ConvertJavaToBedrock.h
  src/ProgressViewController.swift
  src/BridgingHeader.h
  src/AtomicBool.swift
  src/Core.h
  src/Core.mm
  src/ProgressBar.swift
  src/ConversionType.swift
)
set(je2be_ios_resources
  src/ModeSelectViewController.xib
  src/ChooseInputViewController.xib
  src/ProgressViewController.xib
  src/LaunchScreen.storyboard
)

add_executable(je2be-ios MACOSX_BUNDLE ${je2be_ios_files} ${je2be_ios_resources})
set_target_properties(je2be-ios PROPERTIES
  BUNDLE True
  RESOURCE "${je2be_ios_resources}"
  MACOSX_BUNDLE_GUI_IDENTIFIER com.github.kbinani.je2be-ios
  MACOSX_BUNDLE_BUNDLE_NAME je2be-ios
  MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
  MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
  XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET 15.0
  XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "src/BridgingHeader.h"
  XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
  XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
)
target_link_libraries(je2be-ios PRIVATE je2be)
target_sources(je2be-ios PRIVATE assets.xcassets)
set_source_files_properties(assets.xcassets PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
set_property(TARGET je2be-ios PROPERTY XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++20")
set_property(TARGET je2be-ios PROPERTY XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "14.0")
set_property(TARGET je2be-ios PROPERTY XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2")

set_property(TARGET leveldb PROPERTY XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "14.0")
set_property(TARGET minizip PROPERTY XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "14.0")

add_custom_command(TARGET je2be-ios PRE_BUILD COMMAND bash ../script/pre-build.sh)

list(APPEND all_files ${je2be_ios_files} ${je2be_ios_resources})
source_group(TREE ${CMAKE_CURRENT_LIST_DIR} FILES ${all_files})
