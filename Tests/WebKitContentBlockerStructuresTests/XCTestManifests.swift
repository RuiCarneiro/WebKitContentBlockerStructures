import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(WebKitContentBlockerStructuresTests.allTests)
    ]
}
#endif
