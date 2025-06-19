import FirebaseAnalytics
import SwiftUI

// MARK: Tracker
public protocol Tracker {
    func track(event: Event)
}

@propertyWrapper public struct AppTracker: DynamicProperty {
    public var wrappedValue: DefaultTracker
    
    public init() {
        self.wrappedValue = DefaultTracker()
    }
}

public actor DefaultTracker: Tracker {
    public init() {}
    nonisolated public func track(event: Event) {
        if let analyticsEvent = event as? AnalyticsEvent {
            Analytics.logEvent(analyticsEvent.name, parameters: analyticsEvent.parameters?.typeErased)
        } else if let customEvent = event as? CustomEvent {
            Analytics.logEvent(customEvent.name, parameters: customEvent.parameters?.typeErased)
        } else if let userEvent = event as? UserEvent {
            Analytics.setUserProperty(userEvent.value, forName: userEvent.name)
        } else {
            Analytics.logEvent(event.defaultName, parameters: event.defaultParameters)
        }
    }
}

internal extension Dictionary where Key == String, Value == ParameterValueType? {
    var typeErased: [String: Any]? {
        var result: [String: Any] = [:]
        for (key, value) in self {
            if let value = value {
                switch value {
                case .string(let string): result[key] = string
                case .int(let int): result[key] = int
                case .double(let double): result[key] = double
                }
            }
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
            }
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
