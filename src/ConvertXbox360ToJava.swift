
class ConvertXbox360ToJava: Converter {

    let playerUuid: UUID?
    
    init(playerUuid: UUID?) {
        self.playerUuid = playerUuid
    }
    
    func startConvertingFile(_ input: URL, usingTempDirectory tempDirectory: URL, delegate: ConverterDelegate?) {
        Xbox360ToJava(self, input, playerUuid?.uuidString, tempDirectory, delegate);
    }
    
    func numProgressSteps() -> Int32 {
        return 1
    }
    
    func description(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return "Convert"
        default:
            return nil
        }
    }
    
    func displayUnit(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return nil
        default:
            return nil
        }
    }
}
