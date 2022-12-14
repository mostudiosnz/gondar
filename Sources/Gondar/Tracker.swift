import FirebaseAnalytics
import SwiftUI

// MARK: Tracker
public protocol Tracker {
    static var shared: Tracker { get }
    func track(event: Event)
}

public class AppTracker: Tracker {
    public static let shared: Tracker = AppTracker()
    
    public func track(event: Event) {
        if let analyticsEvent = event as? AnalyticsEvent {
            let name = analyticsEvent.name
            let parameters = analyticsEvent.parameters?.compactMapValues { $0 }
            Analytics.logEvent(name, parameters: parameters)
        } else if let customEvent = event as? CustomEvent {
            Analytics.logEvent(customEvent.name, parameters: customEvent.parameters)
        } else if let userEvent = event as? UserEvent {
            Analytics.setUserProperty(userEvent.value, forName: userEvent.name)
        }
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
        into tracker: Tracker = AppTracker.shared,
        @EventBuilder _ events: () -> [Event]
    ) -> some View {
        let modifier = EventTrackingModifier(on: trigger, given: condition, track: events(), into: tracker)
        return self.modifier(modifier)
    }
}

public struct EventTrackingModifier: ViewModifier {
    private let triggeredEventsMap: [EventTrigger: [Event]]
    private let condition: () -> Bool
    private let tracker: Tracker
    
    public init(on trigger: EventTrigger, given condition: @escaping () -> Bool, track events: [Event], into tracker: Tracker) {
        self.triggeredEventsMap = [trigger: events]
        self.condition = condition
        self.tracker = tracker
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear { track(on: .appear) }
            .onDisappear { track(on: .disappear) }
    }
    
    private func track(on trigger: EventTrigger) {
        guard condition() else { return }
        triggeredEventsMap
            .filter { $0.key == trigger }
            .flatMap(\.value)
            .forEach(tracker.track)
    }
}

@resultBuilder public struct EventBuilder {
    public static func buildBlock(_ components: Event...) -> [Event] {
        components
    }
}
