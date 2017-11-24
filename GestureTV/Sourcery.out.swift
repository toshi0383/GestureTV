// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


// swiftlint:disable file_length
fileprivate func compareOptionals<T>(lhs: T?, rhs: T?, compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    switch (lhs, rhs) {
    case let (lValue?, rValue?):
        return compare(lValue, rValue)
    case (nil, nil):
        return true
    default:
        return false
    }
}

fileprivate func compareArrays<T>(lhs: [T], rhs: [T], compare: (_ lhs: T, _ rhs: T) -> Bool) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (idx, lhsItem) in lhs.enumerated() {
        guard compare(lhsItem, rhs[idx]) else { return false }
    }

    return true
}


// MARK: - AutoEquatable for classes, protocols, structs

// MARK: - AutoEquatable for Enums
// MARK: - TouchManager.TouchState AutoEquatable
extension TouchManager.TouchState: Equatable {}
public func == (lhs: TouchManager.TouchState, rhs: TouchManager.TouchState) -> Bool {
    switch (lhs, rhs) {
    case (.touchDown(let lhs), .touchDown(let rhs)):
        return lhs == rhs
    case (.touchUp(let lhs), .touchUp(let rhs)):
        return lhs == rhs
    case (.right(let lhs), .right(let rhs)):
        return lhs == rhs
    case (.left(let lhs), .left(let rhs)):
        return lhs == rhs
    case (.up(let lhs), .up(let rhs)):
        return lhs == rhs
    case (.down(let lhs), .down(let rhs)):
        return lhs == rhs
    case (.unknown, .unknown):
        return true
    default: return false
    }
}
