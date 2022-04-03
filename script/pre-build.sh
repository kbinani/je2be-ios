set -ue

PLISTBUDDY=/usr/libexec/PlistBuddy
INFO_PLIST_PATH=CMakeFiles/je2be-ios.dir/Info.plist

${PLISTBUDDY} -c "Delete :UISupportedInterfaceOrientations" "$INFO_PLIST_PATH" || true
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations array" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationPortrait" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationPortraitUpsideDown" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationLandscapeLeft" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations:0 string UIInterfaceOrientationLandscapeRight" "$INFO_PLIST_PATH"

${PLISTBUDDY} -c "Delete :UISupportedInterfaceOrientations~ipad" "$INFO_PLIST_PATH" || true
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations~ipad array" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations~ipad:0 string UIInterfaceOrientationPortrait" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations~ipad:0 string UIInterfaceOrientationPortraitUpsideDown" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations~ipad:0 string UIInterfaceOrientationLandscapeLeft" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :UISupportedInterfaceOrientations~ipad:0 string UIInterfaceOrientationLandscapeRight" "$INFO_PLIST_PATH"

${PLISTBUDDY} -c "Delete :UIRequiresFullScreen" "$INFO_PLIST_PATH" || true
${PLISTBUDDY} -c "Add :UIRequiresFullScreen bool YES" "$INFO_PLIST_PATH"

${PLISTBUDDY} -c "Delete :UILaunchStoryboardName" "$INFO_PLIST_PATH" || true
${PLISTBUDDY} -c "Add :UILaunchStoryboardName string LaunchScreen" "$INFO_PLIST_PATH"
