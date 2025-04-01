//
//  BannerService.swift
//  Banner
//
//  Created by Dallin Jared on 3/24/23.
//  https://dallinjared.medium.com/swiftui-tutorial-creating-an-in-app-banner-notification-system-97597d64f514
//  Adapted by Alban Thevret on Nov. 10, 2024.
//

import Foundation
import SwiftUI
import Observation

/// A service responsible for managing and displaying banner notifications in the application.
///
/// This class provides functionality to:
/// - Display new banner notifications
/// - Manage the lifecycle of active banners
/// - Handle banner animations and removal
/// - Maintain a limited queue of the most recent banners
///
/// Usage Example:
/// ```swift
/// let service = BannerService.shared
/// service.addBanner(banner: .success("Operation completed successfully"))
/// ```
@available(iOS 17.0, *)
@available(macOS 15.0, *)
@MainActor
@Observable
public class BannerService {
    /// The shared singleton instance of the banner service.
    public static let shared = BannerService()

    /// The collection of all active banners currently in the system.
    public var banners: [Banner] = []

    /// A filtered view of the most recent banners.
    ///
    /// This computed property returns:
    /// - Maximum of 10 most recent banners
    /// - Sorted by date in descending order (newest first)
    public var filteredBanners: [Banner] {
        return Array(
            banners
                .sorted { $0.date > $1.date }
                .prefix(10)
        )
    }

    /// The animation configuration used for banner transitions.
    nonisolated public let animation: Animation = .easeInOut(duration: 0.5)

    /// The delay duration before automatically removing a banner.
    nonisolated private let removalDelay: Double = 1.5

    /// Adds a new banner notification to the service.
    /// - Parameter banner: The type of banner to be displayed.
    public func addBanner(banner: BannerType) {
        let newBanner = Banner(bannerType: banner)
        self.banners.append(newBanner)
    }

    /// Removes a banner with animation.
    /// - Parameter banner: The banner to be removed.
    ///
    /// This method performs a two-step removal process:
    /// 1. Animates the banner off-screen
    /// 2. Removes it from the banners collection after the animation completes
    public func removeBanner(banner: Banner) {
        withAnimation(self.animation) {
            banner.isAnimating = false
            banner.dragOffset.height = -banner.origin.y
        } completion: {
            if let bannerIndex = self.banners.firstIndex(of: banner) {
                self.banners.remove(at: bannerIndex)
            }
        }
    }

    /// Removes a banner after a predefined delay.
    /// - Parameter banner: The banner to be removed.
    ///
    /// The banner will be removed after `removalDelay` seconds (1.5 seconds by default).
    public func removeBannerDelayed(banner: Banner) {
        DispatchQueue.main.asyncAfter(deadline: .now() + removalDelay) {
            self.removeBanner(banner: banner)
        }
    }
}

/// A class representing an individual banner notification.
///
/// Each banner contains information about:
/// - Its type and content
/// - Current animation state
/// - Position and movement information
/// - Creation timestamp
@available(iOS 17.0, *)
@available(macOS 15.0, *)
@Observable
public final class Banner: NSObject, Identifiable {
    /// The unique identifier for the banner, based on its type.
    public var id: BannerType { bannerType }
    
    /// The timestamp when the banner was created.
    public var date: Date
    
    /// Indicates whether the banner is currently animating.
    public var isAnimating: Bool
    
    /// The current drag offset of the banner, used for gesture-based dismissal.
    public var dragOffset: CGSize
    
    /// The original position of the banner in the view hierarchy.
    public var origin: CGPoint
    
    /// The type of the banner, determining its appearance and content.
    public var bannerType: BannerType

    /// Creates a new banner with the specified type.
    /// - Parameter bannerType: The type of banner to create.
    init(bannerType: BannerType) {
        self.date = .now
        self.isAnimating = true
        self.dragOffset = CGSize.zero
        self.origin = CGPoint.zero
        self.bannerType = bannerType
    }
}
