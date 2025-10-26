import FirebaseAnalytics
import SwiftUI
import TelemetryDeck

// MARK: Tracker
public protocol Tracker: Sendable {
    func track(event: Event)
}

public struct AppTracker: Tracker {
    public init() {}
    nonisolated public func track(event: Event) {
        if let purchaseCompletedEvent = event as? PurchaseCompletedEvent, let transaction = purchaseCompletedEvent.transaction {
            Analytics.logEvent(purchaseCompletedEvent.name, parameters: purchaseCompletedEvent.parameters?.typeErased)
            TelemetryDeck.purchaseCompleted(transaction: transaction)
        } else if let analyticsEvent = event as? AnalyticsEvent {
            Analytics.logEvent(analyticsEvent.name, parameters: analyticsEvent.parameters?.typeErased)
            TelemetryDeck.signal(analyticsEvent.name, parameters: analyticsEvent.parameters?.typeString ?? [:])
        } else if let customEvent = event as? CustomEvent {
            Analytics.logEvent(customEvent.name, parameters: customEvent.parameters?.typeErased)
            TelemetryDeck.signal(customEvent.name, parameters: customEvent.parameters?.typeString ?? [:])
        } else if let userEvent = event as? UserEvent {
            Analytics.setUserProperty(userEvent.value, forName: userEvent.name)
            // TelemetryDeck does not support user properties
        } else {
            Analytics.logEvent(event.defaultName, parameters: nil)
            TelemetryDeck.signal(event.defaultName)
        }
    }
}

internal extension Dictionary where Key == String, Value == ParameterValueType? {
    var typeErased: [String: Any]? {
        var result: [String: Any] = [:]
        for (key, value) in self {
            guard let value else { continue }
            switch value {
            case .string(let string): result[key] = string
            case .int(let int): result[key] = int
            case .double(let double): result[key] = double
            case .bool(let bool): result[key] = bool
            }
        }
        return result.isEmpty ? nil : result
    }
    var typeString: [String: String]? {
        var result: [String: String] = [:]
        for (key, value) in self {
            guard let value else { continue }
            result[key] = value.description
        }
        return result.isEmpty ? nil : result
    }
}

internal extension Dictionary where Key == String, Value == ParameterValueType {
    var typeErased: [String: Any]? {
        var result: [String: Any] = [:]
        for (key, value) in self {
            switch value {
            case .string(let string): result[key] = string
            case .int(let int): result[key] = int
            case .double(let double): result[key] = double
            case .bool(let bool): result[key] = bool
            }
        }
        return result.isEmpty ? nil : result
    }
    var typeString: [String: String]? {
        var result: [String: String] = [:]
        for (key, value) in self {
            result[key] = value.description
        }
        return result.isEmpty ? nil : result
    }
}

// MARK: View Extension
public extension View {
    var trackingName: String {
        String(describing: type(of: self).self)
    }
}
