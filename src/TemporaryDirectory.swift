
class TemporaryDirectory {
    let path: URL
    
    init?() {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false)
        } catch {
            return nil
        }
        self.path = path
    }
    
    deinit {
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
        }
    }
}
