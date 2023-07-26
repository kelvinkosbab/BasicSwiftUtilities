# ``CoreHealth``

Provides utilties for accessing Apple's `HealthKit` APIs. These APIs wrap Apple's APIs to provide
useful ways to query data safely via units that each health biometric supports.

Note: `HealthKit`'s APIs will crash the app if the trying to convert a biometric value to an
incompatable unit, which is not very elegant for error handling. This package protects consumers
from this.

## Authorization of `HealthKit` Biometrics

Provides utilities for authorizing and checking authorization status of `HealthKit` biometrics. 

When determining whether requesting authorization for the given biometric is necessary:
- See ``HealthKitAuthorizor/getRequestStatusForAuthorization(toShare:read:)-3lyy7`` ([link](../Authorization/HealthKitAuthorizor.swift))
- See ``HealthKitAuthorizor/getRequestStatusForAuthorization(toShare:read:completion:)-4u26q``  ([link](../Authorization/HealthKitAuthorizor.swift))

When requesting authorization to read or write for the given biometric:
- See ``HealthKitAuthorizor/requestAuthorization(toShare:read:)-46j3n`` ([link](../Authorization/HealthKitAuthorizor.swift))
- See ``HealthKitAuthorizor/requestAuthorization(toShare:read:completion:)-9cqni`` ([link](../Authorization/HealthKitAuthorizor.swift))

## Querying `HealthKit` Biometrics

The ``QueryExecutor`` ([link](../QueryExecutor/QueryExecutor.swift)) protocol defines methods for executing queries for health biometric data
and provides the base mechanism for creating specific queries based on health biometric type.

For example:
```swift
let thirtyDaysAgo = Calendar.current.date(
    byAdding: .day,
    value: -30,
    to: Date()
)!
let startDate = Calendar.current.startOfDay(for: thirtyDaysAgo)

let options = QueryOptions(
    startDate: startDate,
    endDate: Date(),
    limit: .noLimit
)

do {
    self.samples = try await HKHealthStore().fetch(
        .vo2Max,
        in: .mLkgPerMin,
        options: options
    )    
} catch {
    // handle the error
}
```
