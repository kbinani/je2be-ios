set -ue

PLISTBUDDY=/usr/libexec/PlistBuddy
INFO_PLIST_PATH=CMakeFiles/je2be-ios.dir/Info.plist

${PLISTBUDDY} -c "Delete :UISupportedInterfaceOrientations" "$INFO_PLIST_PATH" || true
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations array" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationPortrait" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationPortraitUpsideDown" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationLandscapeLeft" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationLandscapeRight" "$INFO_PLIST_PATH"
