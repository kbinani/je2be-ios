

extension String {
    func substr(with range: Range<Int>) -> String {
        return String(self[self.index(self.startIndex, offsetBy: range.lowerBound) ..< self.index(self.startIndex, offsetBy: range.upperBound)])
    }
}
