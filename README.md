# Gondar

A wrapper around [FirebaseAnalytics](https://github.com/firebase/firebase-ios-sdk) and [Mixpanel](https://github.com/mixpanel/mixpanel-swift) for tracking used throughout MO Studios iOS projects.

## Install

Install using Swift Package Manager.

Version 4.0.0 uses Mixpanel 7.0.0 and requires Xcode 27 or later (the package uses Swift tools 6.2). Supported platforms are iOS 16, macOS 13, watchOS 9, and tvOS 15 or later. The watchOS and tvOS minimums have increased from watchOS 7 and tvOS 14 in Gondar 3.x.

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
