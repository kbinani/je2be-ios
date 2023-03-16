class ConvertJavaToBedrock: Converter {

    func description(forStep step: Int32) -> String? {
        switch step {
        case 0:
            return "Unzip"
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
    
    func numProgressSteps() -> Int32 {
        return 5
    }
    
    func startConvertingFile(_ input: URL, usingTempDirectory tempDirectory: URL, delegate: ConverterDelegate?) {
        JavaToBedrock(self, input, tempDirectory, delegate)
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
            return nil
        case 4:
            return "files"
        default:
            return nil
        }
    }
}
