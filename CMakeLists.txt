cmake_minimum_required(VERSION 3.16)
project(je2be-ios LANGUAGES C CXX Swift VERSION 1.1.0)

set(je2be_iphoneos_deployment_target "15.0")
set(je2be_product_bundle_identifier "com.github.kbinani.je2be-ios")
set(je2be_bugsnag_api_key "44c5703205a25aab4b0673ce6d281bfb")

add_subdirectory(deps/je2be EXCLUDE_FROM_ALL)

set(je2be_ios_files
  src/AppDelegate.swift
  src/MainViewController.swift
  src/ChooseInputViewController.swift
  src/Localization.swift
  src/Converter.h
  src/ConvertJavaToBedrock.swift
  src/ProgressViewController.swift
  src/BridgingHeader.h
  src/AtomicBool.swift
  src/Core.h
  src/Core.mm
  src/ProgressBar.swift
  src/ConversionType.swift
  src/ConvertBedrockToJava.swift
  src/TemporaryDirectory.swift
  src/SecurityScopedResource.swift
  localization/ja-JP.lang
  src/ErrorCode.swift
  src/ErrorViewController.swift
  src/ConvertXbox360ToJava.swift
  src/ConvertXbox360ToBedrock.swift
  src/UserDefaults.swift
  src/UUID.swift
  src/String.swift
)
set(je2be_ios_resources
  src/MainViewController.xib
  src/ChooseInputViewController.xib
  src/ProgressViewController.xib
  src/AboutViewController.xib
  src/LaunchScreen.storyboard
  resource/Settings.bundle
  resource/assets.xcassets
)

add_executable(je2be-ios MACOSX_BUNDLE ${je2be_ios_files} ${je2be_ios_resources})
set_target_properties(je2be-ios PROPERTIES
  BUNDLE True
  RESOURCE "${je2be_ios_resources}"
  MACOSX_BUNDLE_GUI_IDENTIFIER "${je2be_product_bundle_identifier}"
  MACOSX_BUNDLE_BUNDLE_NAME je2be-ios
  MACOSX_BUNDLE_BUNDLE_VERSION "${CMAKE_PROJECT_VERSION}"
  MACOSX_BUNDLE_SHORT_VERSION_STRING "${CMAKE_PROJECT_VERSION}"
  MACOSX_BUNDLE_LONG_VERSION_STRING "${CMAKE_PROJECT_VERSION}"
  MACOSX_BUNDLE_COPYRIGHT "Copyright © kbinani"
  XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "${je2be_product_bundle_identifier}"
  XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "${je2be_iphoneos_deployment_target}"
  XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "src/BridgingHeader.h"
  XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
  XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
  XCODE_ATTRIBUTE_INSTALL_PATH "$(LOCAL_APPS_DIR)"
  XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++20"
  XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "${je2be_iphoneos_deployment_target}"
  XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
  XCODE_ATTRIBUTE_ENABLE_BITCODE "YES"
  XCODE_ATTRIBUTE_SWIFT_PRECOMPILE_BRIDGING_HEADER "NO"
)
target_link_libraries(je2be-ios PRIVATE je2be)
add_custom_command(TARGET je2be-ios PRE_BUILD COMMAND bash ../script/pre-build.sh)

set_source_files_properties(resource/assets.xcassets PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

set_target_properties(leveldb PROPERTIES
  XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "${je2be_iphoneos_deployment_target}"
  XCODE_ATTRIBUTE_ENABLE_BITCODE "YES"
)

set_target_properties(minizip PROPERTIES
  XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "${je2be_iphoneos_deployment_target}"
  XCODE_ATTRIBUTE_ENABLE_BITCODE "YES"
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
)

list(APPEND all_files ${je2be_ios_files} ${je2be_ios_resources})
source_group(TREE ${CMAKE_CURRENT_LIST_DIR} FILES ${all_files})

configure_file(build/Podfile.in Podfile)
configure_file(fastlane/Fastfile.in ../fastlane/Fastfile)
