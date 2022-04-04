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

${PLISTBUDDY} -c "Delete :CFBundleDisplayName" "$INFO_PLIST_PATH" || true
${PLISTBUDDY} -c "Add :CFBundleDisplayName string je2be" "$INFO_PLIST_PATH"

${PLISTBUDDY} -c "Delete :bugsnag" "$INFO_PLIST_PATH" || true
${PLISTBUDDY} -c "Add :bugsnag dict" "$INFO_PLIST_PATH"
${PLISTBUDDY} -c "Add :bugsnag:apiKey string 44c5703205a25aab4b0673ce6d281bfb" "$INFO_PLIST_PATH"
