class ConvertJavaToBedrock: Converter {

    func description(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return "Unzip"
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
    
    func numProgressSteps() -> Int32 {
        return 4
    }
    
    func startConvertingFile(_ input: URL, delegate: ConverterDelegate?) {
        JavaToBedrock(self, input, delegate)
    }
    
    func displayUnit(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return "files"
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
