
class ConvertBedrockToJava: Converter {

    func startConvertingFile(_ input: URL, delegate: ConverterDelegate?) {
        BedrockToJava(self, input, delegate)
    }
    
    func numProgressSteps() -> Int32 {
        return 3
    }
    
    func description(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return "Extract"
        case 1:
            return "Convert"
        case 2:
            return "Zip"
        default:
            return nil
        }
    }
}
