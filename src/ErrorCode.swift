
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
                messages.append(gettext("Uncaught C++ exception") + ": " + what)
            } else {
                messages.append(gettext("Uncaught C++ exception"))
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
        case kJe2beErrorCodeUnzipZipError:
            messages.append(gettext("Unzip error"))
            messages.append(gettext("The zip file is corrupt"))
        case kJe2beErrorCodeUnzipMcworldError:
            messages.append(gettext("Unzip error"))
            messages.append(gettext("The mcworld file is corrupt"))
        case kJe2beErrorCodeLevelDatNotFound:
            messages.append(gettext("level.dat not found in the zip file"))
        case kJe2beErrorCodeMultipleLevelDatFound:
            messages.append(gettext("Multiple level.dat found in the zip file"))
        case kJe2beErrorCodeMcworldTooLarge:
            messages.append(gettext("The size of the mcworld file has exceeded 4 GB"))
        default:
            break
        }
        if let trace = self.userInfo["trace"] as? [Any] {
            messages.append("trace: ")
            trace.forEach { value in
                guard let info = value as? [String: Any] else {
                    return
                }
                guard let file = info["file"] as? String, let line = info["line"] as? Int else {
                    return
                }
                messages.append("  file: \(file) at \(line)")
            }
        } else {
            if let file = self.userInfo["file"] as? String {
                messages.append("file: " + file)
            }
            if let line = self.userInfo["line"] as? Int {
                messages.append("line: \(line)")
            }
        }
        if let what = self.userInfo["what"] as? String, !what.isEmpty {
            messages.append("what: \(what)")
        }
        if messages.isEmpty {
            return nil
        } else {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                messages.append("app version: " + version)
            }
            return messages
        }
    }
}
