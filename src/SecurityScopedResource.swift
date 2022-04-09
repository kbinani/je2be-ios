
class SecurityScopedResource {
    let url: URL
    
    init?(url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            return nil
        }
        self.url = url
    }
    
    deinit {
        self.url.stopAccessingSecurityScopedResource()
    }
}
