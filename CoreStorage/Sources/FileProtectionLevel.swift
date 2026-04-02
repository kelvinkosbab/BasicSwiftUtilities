//
//  FileProtectionLevel.swift
//
//  Copyright © Kozinga. All rights reserved.
//

import Foundation

// MARK: - File Protection Level Utilities

public extension URL {

    /// Changes the data protection level of an existing file.
    ///
    /// Data protection is an iOS feature that you use to secure your app’s files and prevent unauthorized access to them.
    /// Data protection is enabled automatically when the user sets an active passcode for the device. You read and write your
    /// files normally, but the system encrypts and decrypts your content behind the scenes. The encryption and decryption
    /// processes are automatic and hardware accelerated.
    ///
    /// You specify the level of data protection that you want to apply to each of your files. There are four levels available,
    /// each of which determines when you may access the file. If you do not specify a protection level when creating a file,
    /// iOS applies the default protection level automatically.
    ///
    /// - **No protection**. The file is always accessible.
    /// - **Complete until first user authentication**. (**Default**) The file is inaccessible until the first time the user
    /// unlocks the device. After the first unlocking of the device, the file remains accessible until the device shuts down or reboots.
    /// - **Complete unless open**. You can open existing files only when the device is unlocked. If you have a file already
    /// open, you may continue to access that file even after the user locks the device. You can also create new files and access
    /// them while the device is locked or unlocked.
    /// - **Complete**. The file is accessible only when the device is unlocked.
    ///
    /// For more information see Apple's [Encrypting your app's files documentation](https://developer.apple.com/documentation/uikit/protecting_the_user_s_privacy/encrypting_your_app_s_files).
    ///
    /// - Parameter url: URL of the file to update the data protection level.
    /// - Parameter protectionLevel: Data protection level to update the url to.
    func setFileProtection(
        url: URL,
        protectionLevel: URLFileProtection
    ) throws {
        try (url as NSURL).setResourceValue(
            protectionLevel,
            forKey: .fileProtectionKey
        )
    }
}
