@testable import WebKitContentBlockerStructures
import XCTest

final class WebKitContentBlockerStructuresTests: XCTestCase {

    func testActions() {
        XCTAssertNil(WKBLRule.Action(action: .cssDisplayNone), "css display none must have a selector")

        let cssRule = WKBLRule.Action(selectorToNotDisplay: "#a")
        XCTAssert(cssRule.action == .cssDisplayNone)

        let cssAction = WKBLRule.Action(selectorsToNotDisplay: ["#a", ".hide"])

        XCTAssert(cssAction.action == .cssDisplayNone)
        XCTAssert(cssAction.selector == "#a, .hide")

        XCTAssertNil(WKBLRule.Action(action: .cssDisplayNone, selector: nil))

        XCTAssertNil(WKBLRule.Action(action: .blockCookies, selector: "#a"))

        XCTAssertNotNil(WKBLRule.Action(action: .block, selector: nil))

    }

    func testTriggers() {
        XCTAssertNil(WKBLRule.Trigger(urlFilter: nil,
                                      caseSensitiveUrlFilter: true,
                                      resourceTypes: nil,
                                      loadTypes: nil,
                                      ifDomain: nil,
                                      unlessDomain: nil),
                     "Case Sensitive and no filter")

        XCTAssertNil(WKBLRule.Trigger(urlFilter: nil,
                                      caseSensitiveUrlFilter: false,
                                      resourceTypes: nil,
                                      loadTypes: nil,
                                      ifDomain: nil,
                                      unlessDomain: nil),
                     "Case Sensitive and no filter")

        XCTAssertNil(WKBLRule.Trigger(urlFilter: nil,
                                      caseSensitiveUrlFilter: nil,
                                      resourceTypes: nil,
                                      loadTypes: nil,
                                      ifDomain: ["a.com"],
                                      unlessDomain: ["b.com"]),
                     "If domain and unless domain are mutually exclusive")

        let ifDomainCase = WKBLRule.Trigger(ifDomain: ["a.com"],
                                            unlessDomain: nil)

        let unlessDomainCase = WKBLRule.Trigger(ifDomain: nil,
                                                unlessDomain: ["b.com"])

        XCTAssertNotNil(ifDomainCase)
        XCTAssertNotNil(unlessDomainCase)

        XCTAssert(ifDomainCase?.ifDomain?.first == "a.com")
        XCTAssert(unlessDomainCase?.unlessDomain?.first == "b.com")

        let t = WKBLRule.Trigger(urlFilter: "a",
                                 caseSensitiveUrlFilter: true,
                                 resourceTypes: [.font, .document, .document],
                                 loadTypes: [.firstParty, .firstParty, .thirdParty])!

        XCTAssert(t.urlFilter == "a")
        XCTAssert(t.urlFilterIsCaseSensitive == true)
        XCTAssert(t.resourceType?.count == 2)
        XCTAssert(t.loadType?.count == 2)

    }

    func testJsonMaker() {
        let rule = WKBLRule(trigger: WKBLRule.Trigger(urlFilter: #"http://"#)!,
                            action: WKBLRule.Action(action: .blockCookies)!)

        let jsonData = WKBLRule.generateBlocklistJson(rules: [rule])
        let json = String(data: jsonData, encoding: .utf8)!
        print(json)
        let expectedJson = #"""
[
  {
    "trigger" : {
      "url-filter" : "http:\/\/"
    },
    "action" : {
      "action" : "block-cookies"
    }
  }
]
"""#

        XCTAssert(json == expectedJson)
    }

    static var allTests = [
        ("testTriggers", testTriggers),
        ("testActions", testActions),
        ("testJsonMaker", testJsonMaker)
    ]

}
