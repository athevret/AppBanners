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

public enum BannerType: Sendable {
    var id: Self { self }
    case success(
        title: String? = nil,
        message: String,
        isPersistent: Bool = false)
    case error(
        title: String? = nil,
        message: String,
        isPersistent: Bool = true)
    case warning(
        title: String? = nil,
        message: String,
        isPersistent: Bool = false)

    var backgroundColor: Color {
        switch self {
        case .success: return Color.green
        case .warning: return Color.yellow
        case .error: return Color.red
        }
    }

    var imageName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }

    var title: String? {
        switch self {
        case let .success(title, _, _), let .warning(title, _, _), let .error(title, _, _):
            return title
        }
    }

    var message: String? {
        switch self {
        case let .success(_, message, _), let .warning(_, message, _), let .error(_, message, _):
            return message
        }
    }

    var isPersistent: Bool {
        switch self {
        case let .success(_, _, isPersistent), let .warning(_, _, isPersistent), let .error(_, _, isPersistent):
            return isPersistent
        }
    }
}
