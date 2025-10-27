import FirebaseAnalytics
import SwiftUI
import Mixpanel

// MARK: Tracker
public protocol Tracker: Sendable {
    func track(event: Event)
}

public struct AppTracker: Tracker {
    public init() {}
    nonisolated public func track(event: Event) {
        if let analyticsEvent = event as? AnalyticsEvent {
            Analytics.logEvent(analyticsEvent.name, parameters: analyticsEvent.parameters?.typeErased)
            Mixpanel.safeMainInstance()?.track(event: analyticsEvent.name, properties: analyticsEvent.parameters?.typeMixpanelProperties)
        } else if let customEvent = event as? CustomEvent {
            Analytics.logEvent(customEvent.name, parameters: customEvent.parameters?.typeErased)
            Mixpanel.safeMainInstance()?.track(event: customEvent.name, properties: customEvent.parameters?.typeMixpanelProperties)
        } else if let userEvent = event as? UserEvent {
            Analytics.setUserProperty(userEvent.value?.description, forName: userEvent.name)
            Mixpanel.safeMainInstance()?.people?.set(property: userEvent.name, to: userEvent.value?.value)
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
    var typeMixpanelProperties: Properties? {
        var result: [String: MixpanelType] = [:]
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
    var typeMixpanelProperties: Properties? {
        var result: [String: MixpanelType] = [:]
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
}

// MARK: View Extension
public extension View {
    var trackingName: String {
        String(describing: type(of: self).self)
    }
}
