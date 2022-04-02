class AtomicBool {
    private let semaphore = DispatchSemaphore(value: 1)
    private var flag: Bool
    
    init(initial: Bool) {
        self.flag = initial
    }
    
    func test() -> Bool {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        return flag
    }
    
    @discardableResult
    func getAndSet(value: Bool) -> Bool {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        let ret = flag
        flag = value
        return ret
    }
}
