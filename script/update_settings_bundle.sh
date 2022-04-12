set -ue

PLISTBUDDY=/usr/libexec/PlistBuddy

echo "Set JE2BE_BUILD_CONFIGURATION to $CONFIGURATION"
${PLISTBUDDY} -c "Delete :JE2BE_BUILD_CONFIGURATION" "$INFOPLIST_FILE" || true
${PLISTBUDDY} -c "Add :JE2BE_BUILD_CONFIGURATION string $CONFIGURATION" "$INFOPLIST_FILE"