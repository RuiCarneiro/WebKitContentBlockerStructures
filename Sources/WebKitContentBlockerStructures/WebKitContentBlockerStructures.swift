import Foundation

public struct WKBLRule: Codable {
    public struct Trigger: Codable {

        public enum ResourceType: String, Codable {
            case document
            case image
            case styleSheet = "style-sheet"
            case script
            case font
            case raw
            case svgDocument = "svg-document"
            case media
            case popup
        }

        public enum LoadType: String, Codable {
            case firstParty = "first-party"
            case thirdParty = "third-party"
        }

        public var urlFilter: String
        public var urlFilterIsCaseSensitive: Bool?
        public var resourceType: [ResourceType]?
        public var loadType: [LoadType]?
        public var ifDomain: [String]?
        public var unlessDomain: [String]?

        enum CodingKeys: String, CodingKey {
            case urlFilter = "url-filter"
            case urlFilterIsCaseSensitive = "url-filter-is-case-sensitive"
            case resourceType = "resource-type"
            case loadType = "load-type"
            case ifDomain = "if-domain"
            case unlessDomain = "unless-domain"
        }

        public init?(urlFilter: String? = nil,
                     caseSensitiveUrlFilter: Bool? = nil,
                     resourceTypes: [ResourceType]? = nil,
                     loadTypes: [LoadType]? = nil,
                     ifDomain: [String]? = nil,
                     unlessDomain: [String]? = nil) {

            // case sensitive url filter must have a url filter
            if urlFilter == nil, caseSensitiveUrlFilter != nil {
                return nil
            }

            // ifDomain is incompatible with unlessDomain and vice versa
            let bothNil = ifDomain == nil && unlessDomain == nil
            let ifOption = ifDomain != nil && unlessDomain == nil
            let unlessOption = unlessDomain != nil && ifDomain == nil

            guard bothNil || ifOption || unlessOption else {
                return nil
            }

            // Begin init

            if let uf = urlFilter {
                self.urlFilter = uf
            }
            else {
                self.urlFilter = ".*"
            }

            if let csuf = caseSensitiveUrlFilter {
                self.urlFilterIsCaseSensitive = csuf
            }

            if let rts = resourceTypes {
                self.resourceType = Array(Set(rts))
            }

            if let lts = loadTypes {
                self.loadType = Array(Set(lts))
            }

            if let ifd = ifDomain {
                self.ifDomain = Array(Set(ifd))
            }

            if let ud = unlessDomain {
                self.unlessDomain = Array(Set(ud))
            }
        }
    }

    public struct Action: Codable {

        public enum ActionType: String, Codable {
            case block = "block"
            case blockCookies = "block-cookies"
            case cssDisplayNone = "css-display-none"
            case ignorePreviousRules = "ignore-previous-rules"
        }

        public var type: ActionType
        public var selector: String?

        public init(selectorToNotDisplay: String) {
            self = Action(type: .cssDisplayNone, selector: selectorToNotDisplay)!
        }

        public init(selectorsToNotDisplay: [String]) {
            self = Action(selectorToNotDisplay: selectorsToNotDisplay.joined(separator: ", "))
        }

        public init?(type: ActionType, selector: String? = nil) {
            if type == .cssDisplayNone, selector == nil {
                return nil
            }

            if selector != nil, type != .cssDisplayNone {
                return nil
            }

            self.type = type
            self.selector = selector
        }
    }

    public var trigger: Trigger
    public var action: Action

    public init(trigger: Trigger, action: Action) {
        self.trigger = trigger
        self.action = action
    }

    public static func generateBlocklistJson(rules: [WKBLRule]) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try! encoder.encode(rules)
    }
}
