
class ConvertXbox360ToBedrock: Converter {

    func startConvertingFile(_ input: URL, usingTempDirectory tempDirectory: URL, delegate: ConverterDelegate?) {
        Xbox360ToBedrock(self, input, tempDirectory, delegate);
    }
    
    func numProgressSteps() -> Int32 {
        return 5
    }
    
    func description(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return "Extract"
        case 1:
            return "Convert"
        case 2:
            return "Post Process"
        case 3:
            return "LevelDB Compaction"
        case 4:
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
            return nil
        case 4:
            return "files"
        default:
            return nil
        }
    }
}
