
extension UUID {
    static func fromUUIDString(_ s: String) -> UUID? {
        if let u = UUID(uuidString: s) {
            return u
        }
        let r = s.replacingOccurrences(of: "-", with: "")
        guard r.count == 32 else {
            return nil
        }
        let elements: [String] = [
            r.substr(with: 0 ..< 8),
            r.substr(with: 8 ..< 8 + 4),
            r.substr(with: 8 + 4 ..< 8 + 4 + 4),
            r.substr(with: 8 + 4 + 4 ..< 8 + 4 + 4 + 4),
            r.substr(with: 8 + 4 + 4 + 4 ..< r.count),
        ]
        let n = elements.joined(separator: "-")
        return UUID(uuidString: n)
    }
}
