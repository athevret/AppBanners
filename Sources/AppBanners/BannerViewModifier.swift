//
//  BannerViewModifier.swift
//  Accounts
//
//  Created by Alban THEVRET on 11/11/2024.
//

import SwiftUI

@available(iOS 17.0, *)
@available(macOS 15.0, *)
public struct BannerViewModifier: ViewModifier {
    @State private var bannerService = BannerService.shared
    @Binding var isPresented: Bool
    let banner: BannerType

    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            .onChange(of: $isPresented.wrappedValue) { _, newValue in
                if newValue {
                    bannerService.addBanner(banner: banner)
                    $isPresented.wrappedValue = false
                }
            }
        }
    }
}

extension View {
    @available(iOS 17.0, *)
    @available(macOS 15.0, *)
    public func banner(
        isPresented: Binding<Bool>,
        banner: BannerType
    ) -> some View {
        modifier(
            BannerViewModifier(isPresented: isPresented, banner: banner)
        )
    }
}

#if DEBUG
@available(iOS 17.0, *)
@available(macOS 15.0, *)
struct BannerViewModifier_Previews: PreviewProvider {
    @State static var isErrorPresented: Bool = false
    @State static var isWarningPresented: Bool = false
    @State static var isSuccessPresented: Bool = false
    @State static var bannerService = BannerService()

    static var previews: some View {

        ZStack {
            VStack {
                Button {
                    isErrorPresented = true
                } label: {
                    Text("Error Banner")
                }.padding()

                Button {
                    isWarningPresented = true
                } label: {
                    Text("Warning Banner")
                }.padding()

                Button {
                    isSuccessPresented = true
                } label: {
                    Text("Success Banner")
                }.padding()
            }
            .banner(isPresented: $isErrorPresented,
                    banner: .error(title: "Error Title", message: "Error Message"))
            .banner(isPresented: $isWarningPresented,
                    banner: .warning(title: "Warning Title", message: "Warning Message"))
            .banner(isPresented: $isSuccessPresented,
                    banner: .success(title: "Success Title", message: "Success Message"))

            BannersView()
        }
        .environment(bannerService)
    }
}
#endif
