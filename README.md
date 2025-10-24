# Gondar

A wrapper around [FirebaseAnalytics](https://github.com/firebase/firebase-ios-sdk) and [TelemetryDeck](https://github.com/TelemetryDeck/SwiftSDK) for tracking used throughout MO Studios iOS projects.

## Install

Install using Swift Package Manager.

## Usage

Create an `AppTracker` instance and use it throughout the app. Recommended approach is to set it on the environment and use it throughout the app. Use either the built-in [FirebaseAnalytics Events](https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants) or define and use `CustomEvent`s and even `UserEvent`s.

An extension is also provided on `SwiftUI.View` to make it easy to track `ScreenViewedEvent`s:

```
// SomeView.swift

import SwiftUI

struct AppTrackerKey: EnvironmentKey {
    static let defaultValue = AppTracker()
}

extension EnvironmentValues {
    var tracker: AppTracker {
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
