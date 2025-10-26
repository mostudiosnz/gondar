// MARK: Event
public protocol Event: Sendable {}

public enum ParameterValueType : Sendable, CustomStringConvertible {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    var value: Any {
        switch self {
        case .string(let string): return string
        case .int(let int): return int
        case .double(let double): return double
        case .bool(let bool): return bool
        }
    }
    public var description: String {
        return switch self {
        case let .string(string): string
        case let .int(int): String(describing: int)
        case let .double(double): String(describing: double)
        case let .bool(bool): String(describing: bool)
        }
    }
}

public extension Event {
    var defaultName: String { String(describing: type(of: self)) }
    var defaultParameters: [String: ParameterValueType]? { nil }
    var defaultValue: String? { nil }
}

public enum EventTrigger {
    case appear, disappear
}

public protocol CustomEvent: Event {
    var name: String { get }
    var parameters: [String: ParameterValueType]? { get }
}

extension CustomEvent {
    var name: String { defaultName }
    var parameters: [String: ParameterValueType]? { defaultParameters }
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
import StoreKit

public protocol AnalyticsEvent: Event {
    var name: String { get }
    var parameters: [String: ParameterValueType?]? { get }
}

public struct ScreenViewedEvent: AnalyticsEvent {
    public let name = AnalyticsEventScreenView
    public let parameters: [String : ParameterValueType?]?
    
    public init(name: String) {
        parameters = [
            AnalyticsParameterScreenClass: .string(name),
            AnalyticsParameterScreenName: .string(name)
        ]
    }
}

public struct PurchaseCompletedEvent: AnalyticsEvent {
    public let name = AnalyticsEventPurchase
    public let parameters: [String : ParameterValueType?]?
    internal let transaction: Transaction?
    
    public init(transaction: Transaction) {
        if let currency = transaction.currency, let price = transaction.price.map(NSDecimalNumber.init(decimal:)) {
            parameters = [
                AnalyticsParameterTransactionID: .string(transaction.productID),
                AnalyticsParameterCurrency: .string(currency.identifier),
                AnalyticsParameterValue: .double(price.doubleValue),
            ]
        } else {
            parameters = nil
        }
        self.transaction = transaction
    }
    
    public init(
        transactionId: String,
        currency: String,
        value: Double
    ) {
        parameters = [
            AnalyticsParameterTransactionID: .string(transactionId),
            AnalyticsParameterCurrency: .string(currency),
            AnalyticsParameterValue: .double(value),
        ]
        transaction = nil
    }
}

public struct PurchaseStartedEvent: AnalyticsEvent {
    public let name = AnalyticsEventBeginCheckout
    public let parameters: [String : ParameterValueType?]?
    
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
            AnalyticsParameterCurrency: .string(currency),
            AnalyticsParameterItems: nil, // Optional<Array>
            AnalyticsParameterValue: .double(value)
        ]
    }
}

public struct StoreViewedEvent: AnalyticsEvent {
    public let name = AnalyticsEventViewCart
    public let parameters: [String : ParameterValueType?]? = nil
    
    public init() {}
}
