//
//  BannerView.swift
//  Banner
//
//  Created by Dallin Jared on 3/24/23.
//  https://dallinjared.medium.com/swiftui-tutorial-creating-an-in-app-banner-notification-system-97597d64f514
//  Adapted by Alban Thevret on Nov. 10, 2024.
//

import SwiftUI

struct BannersView: View {
    @State private var bannerService = BannerService.shared
    @State private var showAllText: Bool = false

    let maxDragOffsetHeight: CGFloat = -50.0
    var body: some View {
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
