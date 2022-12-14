// MARK: Event
public protocol Event {}

public extension Event {
    var defaultName: String { String(describing: type(of: self)) }
    var defaultParameters: [String: Any]? { nil }
    var defaultValue: String? { nil }
}

public enum EventTrigger {
    case appear, disappear
}

public protocol CustomEvent: Event {
    var name: String { get }
    var parameters: [String: Any]? { get }
}

extension CustomEvent {
    var name: String { defaultName }
    var parameters: [String: Any]? { defaultParameters }
}

public protocol UserEvent: Event {
    var name: String { get }
    var value: String? { get }
}

extension UserEvent {
    var name: String { defaultName }
    var value: String? { defaultValue }
}

// MARK: AnalyticsEvent
import FirebaseAnalytics

public protocol AnalyticsEvent: Event {
    var name: String { get }
    var parameters: [String: Any?]? { get }
}

public struct ScreenViewedEvent: AnalyticsEvent {
    public let name = AnalyticsEventScreenView
    public let parameters: [String : Any?]?
    
    public init(name: String) {
        parameters = [
            AnalyticsParameterScreenClass: name,
            AnalyticsParameterScreenName: name
        ]
    }
}

public struct PurchaseCompletedEvent: AnalyticsEvent {
    public let name = AnalyticsEventPurchase
    public let parameters: [String : Any?]?
    
    public init() {
        // Current StoreKit2 APIs do not provide enough information to fill in currency and value
        parameters = nil
    }
    
    public init(
        affiliation: String? = nil,
        currency: String,
        transactionId: String,
        value: Double
    ) {
        parameters = [
            AnalyticsParameterAffiliation: affiliation,
            AnalyticsParameterCoupon : nil, // Optional<String>
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterItems: nil, // Optional<Array>
            AnalyticsParameterShipping : nil, // Optional<Double>
            AnalyticsParameterTax: nil, // Optional<Double>
            AnalyticsParameterTransactionID: transactionId,
            AnalyticsParameterValue: value
        ]
    }
}

public struct PurchaseStartedEvent: AnalyticsEvent {
    public let name = AnalyticsEventBeginCheckout
    public let parameters: [String : Any?]?
    
    public init() {
        // Current StoreKit2 APIs do not provide enough information to fill in currency and value
        parameters = nil
    }
    
    public init(
        currency: String,
        value: Double
    ) {
        parameters = [
            AnalyticsParameterCoupon : nil, // Optional<String>
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterItems: nil, // Optional<Array>
            AnalyticsParameterValue: value
        ]
    }
}

public struct StoreViewedEvent: AnalyticsEvent {
    public let name = AnalyticsEventViewCart
    public let parameters: [String : Any?]? = nil
    
    public init() {}
}
