
extension NSError {

    var je2beLocalizedMessages: [String]? {
        guard self.domain == kJe2beErrorDomain else {
            return nil
        }
        var messages: [String] = []
        let code = Je2beErrorCode(Int32(self.code))
        switch code {
        case kJe2beErrorCodeCancelled:
            return nil
        case kJe2beErrorCodeConverterError:
            messages.append(gettext("Internal error of converter"))
        case kJe2beErrorCodeCxxStdException:
            if let what = self.userInfo["what"] as? String {
                messages.append(gettext("Uncaught c++ exception") + ": " + what)
            } else {
                messages.append(gettext("Uncaught c++ exception"))
            }
        case kJe2beErrorCodeIOError:
            messages.append(gettext("IO error"))
        case kJe2beErrorCodeGeneralException:
            if let what = self.userInfo["what"] as? String {
                messages.append(gettext("Uncaught general exception") + ": " + what)
            } else {
                messages.append(gettext("Uncaught general exception"))
            }
        case kJe2beErrorCodeUnknown:
            messages.append(gettext("Unknown error"))
        default:
            break
        }
        if let file = self.userInfo["file"] as? String {
            messages.append("file: " + file)
        }
        if let line = self.userInfo["line"] as? Int {
            messages.append("line: \(line)")
        }
        if messages.isEmpty {
            return nil
        } else {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                messages.append("version: " + version)
            }
            return messages
        }
    }
}
