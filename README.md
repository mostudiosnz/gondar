# Gondar

A wrapper around [FirebaseAnalytics](https://github.com/firebase/firebase-ios-sdk) tracking used throughout MO Studios iOS projects.

## Install

Install using Swift Package Manager.

## Usage

A singleton `Tracker` object is provided. Use either the built-in [FirebaseAnalytics Events](https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants) or define and use `CustomEvent`s and even `UserEvent`s.

An extension is also provided on `SwiftUI.View` to make it easy to track `ScreenViewedEvent`s:

```
// SomeView.swift

struct SomeView: View {
  var body: some View {
    VStack {
      ...
    }.track(on: .appear) {
      ScreenViewedEvent(name: "SomeView")
    }
  }
}

struct AnotherView: View {
  var body: some View {
    VStack {
      ...
    }.track(
      on: .disappear, 
      given: { isConditionMet },
      events: {
        TrackOnDisappearEvent()
        AnotherEvent()
      }
    )
  }
}
```
