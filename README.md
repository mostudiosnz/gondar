# Gondar

A wrapper around [FirebaseAnalytics](https://github.com/firebase/firebase-ios-sdk) and [TelemetryDeck](https://github.com/TelemetryDeck/SwiftSDK) for tracking used throughout MO Studios iOS projects.

## Install

Install using Swift Package Manager.

## Usage

Create an `AppTracker` instance and use it throughout the app. Recommended approach is to set it on the environment and use it throughout the app, but it can be constructed whenever as it is stateless.

```
// SomeView.swift

import SwiftUI

struct AppTrackerKey: EnvironmentKey {
    static let defaultValue: any Tracker = AppTracker()
}

extension EnvironmentValues {
    var tracker: any Tracker {
        get { self[AppTrackerKey.self] }
        set { self[AppTrackerKey.self] = newValue }
    }
}

struct SomeView: View {
  @Environment(\.tracker) var tracker
  var body: some View {
    VStack {
      ...
    }.onAppear {
      tracker.track(event: ScreenViewedEvent(name: "SomeView"))
    }
  }
}
```
