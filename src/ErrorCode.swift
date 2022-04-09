
extension Je2beErrorCode {
    var description: String {
        switch self.rawValue {
        case kJe2beErrorCodeCancelled.rawValue:
            return gettext("Cancelled")
        default:
            return gettext("Failed")
        }
    }
}
