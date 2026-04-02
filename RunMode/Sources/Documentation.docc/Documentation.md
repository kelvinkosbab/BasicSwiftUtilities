# ``RunMode``

Determines the active run mode off the current process.

Possibilities include:
 - Main application
 - Unit tests
 - UI unit tests

To determine the current process's ``RunMode``:
```swift
let activeRunMode = RunMode.getActive()
```
