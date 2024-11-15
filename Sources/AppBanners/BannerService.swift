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

@available(iOS 17.0, *)
@available(macOS 15.0, *)
@MainActor
@Observable
public class BannerService {
    public static let shared = BannerService()

    public var banners: [Banner] = []
    public var filteredBanners: [Banner] {
        return Array(
            banners
                .sorted { $0.date > $1.date }
                .prefix(10)
        )
    }
    nonisolated public let animation: Animation = .easeInOut(duration: 0.5)
    nonisolated private let removalDelay: Double = 1.5

    public func addBanner(banner: BannerType) {
        let newBanner = Banner(bannerType: banner)
        self.banners.append(newBanner)
    }

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

    public func removeBannerDelayed(banner: Banner) {
        DispatchQueue.main.asyncAfter(deadline: .now() + removalDelay) {
            self.removeBanner(banner: banner)
        }
    }
}

@available(iOS 17.0, *)
@available(macOS 15.0, *)
@Observable
public final class Banner: NSObject, Identifiable {
    public var id: BannerType { bannerType }
    public var date: Date
    public var isAnimating: Bool
    public var dragOffset: CGSize
    public var origin: CGPoint
    public var bannerType: BannerType

    init(bannerType: BannerType) {
        self.date = .now
        self.isAnimating = true
        self.dragOffset = CGSize.zero
        self.origin = CGPoint.zero
        self.bannerType = bannerType
    }
}
