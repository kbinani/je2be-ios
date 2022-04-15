
class ConvertXbox360ToBedrock: Converter {

    func startConvertingFile(_ input: URL, usingTempDirectory tempDirectory: URL, delegate: ConverterDelegate?) {
        Xbox360ToBedrock(self, input, tempDirectory, delegate);
    }
    
    func numProgressSteps() -> Int32 {
        return 4
    }
    
    func description(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return "Extract"
        case 1:
            return "Convert"
        case 2:
            return "LevelDB Compaction"
        case 3:
            return "Zip"
        default:
            return nil
        }
    }
    
    func displayUnit(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return nil
        case 1:
            return "chunks"
        case 2:
            return nil
        case 3:
            return "files"
        default:
            return nil
        }
    }
}
