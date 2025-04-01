//
//  BannerType.swift
//  Banner
//
//  Created by Dallin Jared on 3/24/23..
//  https://dallinjared.medium.com/swiftui-tutorial-creating-an-in-app-banner-notification-system-97597d64f514
//  Adapted by Alban Thevret on Nov. 10, 2024.
//

import Foundation
import SwiftUI

/// Represents different types of banner notifications that can be displayed in the application.
///
/// This enum defines three main types of banners:
/// - Success: For positive confirmations and completed actions
/// - Error: For error messages and failures
/// - Warning: For cautionary messages and potential issues
///
/// Each banner type can include:
/// - An optional title
/// - A required message
/// - A persistence flag
///
/// Usage Example:
/// ```swift
/// let successBanner = BannerType.success(
///     title: "Upload Complete",
///     message: "Your file has been uploaded successfully",
///     isPersistent: false
/// )
/// ```
public enum BannerType: Sendable {
    /// The unique identifier for the banner type.
    var id: Self { self }

    /// Represents a success banner with a green background and checkmark icon.
    /// - Parameters:
    ///   - title: Optional title text for the banner
    ///   - message: The main message to display
    ///   - isPersistent: Whether the banner should persist until manually dismissed (defaults to false)
    case success(
        title: String? = nil,
        message: String,
        isPersistent: Bool = false)

    /// Represents an error banner with a red background and X icon.
    /// - Parameters:
    ///   - title: Optional title text for the banner
    ///   - message: The error message to display
    ///   - isPersistent: Whether the banner should persist until manually dismissed (defaults to true)
    case error(
        title: String? = nil,
        message: String,
        isPersistent: Bool = true)

    /// Represents a warning banner with a yellow background and exclamation triangle icon.
    /// - Parameters:
    ///   - title: Optional title text for the banner
    ///   - message: The warning message to display
    ///   - isPersistent: Whether the banner should persist until manually dismissed (defaults to false)
    case warning(
        title: String? = nil,
        message: String,
        isPersistent: Bool = false)

    /// The background color associated with each banner type.
    ///
    /// - Success: Green
    /// - Warning: Yellow
    /// - Error: Red
    var backgroundColor: Color {
        switch self {
        case .success: return Color.green
        case .warning: return Color.yellow
        case .error: return Color.red
        }
    }

    /// The SF Symbol name for the icon displayed in the banner.
    ///
    /// - Success: checkmark.circle.fill
    /// - Warning: exclamationmark.triangle.fill
    /// - Error: xmark.circle.fill
    var imageName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }

    /// The optional title text of the banner.
    ///
    /// Returns nil if no title was provided when creating the banner.
    var title: String? {
        switch self {
        case let .success(title, _, _), let .warning(title, _, _), let .error(title, _, _):
            return title
        }
    }

    /// The main message text of the banner.
    var message: String? {
        switch self {
        case let .success(_, message, _), let .warning(_, message, _), let .error(_, message, _):
            return message
        }
    }

    /// Indicates whether the banner should persist until manually dismissed.
    ///
    /// Default values:
    /// - Success: false
    /// - Warning: false
    /// - Error: true
    var isPersistent: Bool {
        switch self {
        case let .success(_, _, isPersistent), let .warning(_, _, isPersistent), let .error(_, _, isPersistent):
            return isPersistent
        }
    }
}
