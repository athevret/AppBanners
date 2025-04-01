//
//  BannerView.swift
//  Banner
//
//  Created by Dallin Jared on 3/24/23.
//  https://dallinjared.medium.com/swiftui-tutorial-creating-an-in-app-banner-notification-system-97597d64f514
//  Adapted by Alban Thevret on Nov. 10, 2024.
//

import SwiftUI

/// A view that displays and manages a stack of banner notifications.
///
/// This view provides:
/// - Animated banner presentation and dismissal
/// - Gesture-based dismissal with drag interactions
/// - Automatic dismissal for non-persistent banners
/// - Expandable text for long messages
/// - Localization support for banner content
///
/// Usage Example:
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         ZStack {
///             MainContent()
///             BannersView()
///         }
///     }
/// }
/// ```
@available(iOS 17.0, *)
@available(macOS 15.0, *)
public struct BannersView: View {
    /// The shared service managing banner state and lifecycle.
    @State private var bannerService = BannerService.shared
    
    /// Controls whether the banner text is fully expanded.
    @State private var showAllText: Bool = false

    /// The maximum height for drag-based dismissal gesture.
    let maxDragOffsetHeight: CGFloat = -50.0

    /// Creates a new banner view.
    public init() {
    }

    /// The main view body displaying a stack of banner notifications.
    public var body: some View {
        VStack(alignment: .center) {
            withAnimation(bannerService.animation) {
                ForEach(bannerService.banners) { banner in
                    bannerView(banner: banner)
                    .background(
                        GeometryReader { geometryProxy in
                            HStack {}
                                .onAppear {
                                    let origin = geometryProxy.frame(in: .global).origin
                                    banner.origin = origin
                                    banner.dragOffset.height = -origin.y
                                    withAnimation(bannerService.animation) {
                                        banner.dragOffset = .zero
                                    }
                                }
                        }
                    )
                    .onAppear {
                        // Create haptic effect depending on banner type
                        switch banner.bannerType {
                        case .warning: triggerWarningHaptic()
                        case .error: triggerErrorHaptic()
                        default: break
                        }
                        // Defer banner removal if not persistent
                        guard !banner.bannerType.isPersistent else { return }
                        bannerService.removeBannerDelayed(banner: banner)
                    }
                    .offset(y: banner.dragOffset.height)
                    .opacity(
                        banner.isAnimating ?
                            max(0, (1.0 + Double(banner.dragOffset.height) / banner.origin.y)) : 0
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if gesture.translation.height < 0 {
                                    banner.dragOffset = gesture.translation
                                }
                            }
                            .onEnded { _ in
                                if banner.dragOffset.height < -30 {
                                    bannerService.removeBanner(banner: banner)
                                } else {
                                    banner.dragOffset = .zero
                                }
                            }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
    }
    
    /// Create an haptic feedback for error banner
    private func triggerErrorHaptic() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
    }

    /// Create an haptic feedback for warning banner
    private func triggerWarningHaptic() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }

    /// Creates a view for an individual banner notification.
    ///
    /// This view includes:
    /// - An icon representing the banner type
    /// - Title and message text with dynamic font sizing
    /// - Expandable text for long messages
    /// - A close button for persistent banners
    /// - Gesture support for expanding/collapsing long text
    ///
    /// - Parameter banner: The banner model to display
    /// - Returns: A configured view for the banner
    @ViewBuilder
    private func bannerView(banner: Banner) -> some View {
        // swiftlint:disable:previous function_body_length
        HStack(spacing: 10) {
            Image(systemName: banner.bannerType.imageName)
                .padding(5)
                .background(banner.bannerType.backgroundColor)
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.2), radius: 3.0, x: -3, y: 4)
            VStack(spacing: 5) {
                let (count, title, message) = {
                    var count: Int = 0
                    var title: String?
                    var message: String?
                    if let titleKey = banner.bannerType.title {
                        let uwTitle = NSLocalizedString(titleKey, comment: "")
                        title = uwTitle
                        count += uwTitle.count
                    }
                    if let messageKey = banner.bannerType.message {
                        let uwMessage = NSLocalizedString(messageKey, comment: "")
                        message = uwMessage
                        count += uwMessage.count
                    }
                    return (count, title, message)
                }()
                HStack {
                    if let title {
                        Text(title + ":")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    if let message {
                        Text(message)
                            .foregroundColor(.black)
                            .fontWeight(.light)
                    }
                }
                .font(count > 25 ? .caption : .footnote)
                .multilineTextAlignment(.leading)
                .lineLimit(showAllText ? nil : 2)
                if count > 100 && banner.bannerType.isPersistent {
                    Image(systemName: self.showAllText ? "chevron.compact.up" : "chevron.compact.down")
                        .foregroundColor(Color.white.opacity(0.6))
                        .fontWeight(.light)
                }
            }
            banner.bannerType.isPersistent ?
            Button {
                bannerService.removeBanner(banner: banner)
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .shadow(color: .black.opacity(0.2), radius: 3.0, x: 3, y: 4)
            : nil
        }
        .foregroundColor(.white)
        .padding(8)
        .padding(.trailing, 2)
        .background(banner.bannerType.backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 3.0, x: -2, y: 2)
        .onTapGesture {
            withAnimation {
                self.showAllText.toggle()
            }
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
@available(macOS 15.0, *)
struct BannerView_Previews: PreviewProvider {
    @State static private var bannerService = BannerService.shared

    static var previews: some View {
        BannersView()
        .onAppear {
            bannerService.addBanner(banner: .error(title: "Error", message: "Error message 1!"))
            bannerService.addBanner(banner: .warning(title: "Warning", message: "Warning message 2!"))
            bannerService.addBanner(banner: .error(title: "Error", message: "Error message 3!"))
            bannerService.addBanner(banner: .error(title: "Error", message: """
                Very Very Very Very Very Very Very Very Very Very \
                Very Very Very Very Very Very Long Error message 4!
                """))
        }
    }
}
#endif
