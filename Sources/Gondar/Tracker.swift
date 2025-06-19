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
    
    func track(
        on trigger: EventTrigger,
        given condition: @escaping () -> Bool = { true },
        @EventBuilder _ events: () -> [Event]
    ) -> some View {
        let modifier = EventTrackingModifier(
            on: trigger,
            given: condition,
            track: events()
        )
        return self.modifier(modifier)
    }
}

struct EventTrackingWrapperView<Content: View>: View {
    @AppTracker var tracker
    let content: Content
    private let triggeredEventsMap: [EventTrigger: [Event]]
    private let condition: () -> Bool

    @State private var onAppearTracked = false
    @State private var onDisappearTracked = false

    init(
        content: Content,
        triggeredEventsMap: [EventTrigger: [Event]],
        condition: @escaping () -> Bool
    ) {
        self.content = content
        self.triggeredEventsMap = triggeredEventsMap
        self.condition = condition
    }

    var body: some View {
        content
            .onAppear {
                defer { onAppearTracked = true }
                guard !onAppearTracked else { return }
                track(on: .appear)
            }
            .onDisappear {
                defer { onDisappearTracked = true }
                guard !onDisappearTracked else { return }
                track(on: .disappear)
            }
    }

    private func track(on trigger: EventTrigger) {
        guard condition() else { return }
        triggeredEventsMap[trigger]?.forEach(tracker.track)
    }
}

public struct EventTrackingModifier: ViewModifier {
    private let triggeredEventsMap: [EventTrigger: [Event]]
    private let condition: () -> Bool

    public init(on trigger: EventTrigger, given condition: @escaping () -> Bool, track events: [Event]) {
        self.triggeredEventsMap = [trigger: events]
        self.condition = condition
    }

    public func body(content: Content) -> some View {
        EventTrackingWrapperView(
            content: content,
            triggeredEventsMap: triggeredEventsMap,
            condition: condition
        )
    }
}

@resultBuilder public struct EventBuilder {
    public static func buildBlock(_ components: Event...) -> [Event] {
        components
    }
}
