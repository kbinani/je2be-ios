
extension NSError {

    var je2beLocalizedMessages: [String]? {
        guard self.domain == kJe2beErrorDomain else {
            return nil
        }
        let code = Je2beErrorCode(Int32(self.code))
        switch code {
        case kJe2beErrorCodeCancelled:
            return nil
        case kJe2beErrorCodeConverterError:
            return [gettext("Converter failed")]
        case kJe2beErrorCodeCxxStdException:
            if let what = self.userInfo["what"] as? String {
                return [gettext("Uncaught c++ exception") + ": " + what]
            } else {
                return [gettext("Uncaught c++ exception")]
            }
        default:
            //TODO:
            return nil
        }
    }
}
