//
//  BannerViewModifier.swift
//  Accounts
//
//  Created by Alban THEVRET on 11/11/2024.
//

import SwiftUI

/// A view modifier that adds banner notification functionality to any view.
///
/// This modifier enables views to present banner notifications by:
/// - Binding to a presentation state
/// - Managing banner lifecycle through the shared BannerService
/// - Automatically resetting presentation state after showing
///
/// Usage Example:
/// ```swift
/// struct ContentView: View {
///     @State private var showBanner = false
///
///     var body: some View {
///         Button("Show Error") {
///             showBanner = true
///         }
///         .banner(
///             isPresented: $showBanner,
///             banner: .error(title: "Error", message: "Something went wrong")
///         )
///     }
/// }
/// ```
@available(iOS 17.0, *)
@available(macOS 15.0, *)
public struct BannerViewModifier: ViewModifier {
    /// The shared service managing banner state and lifecycle.
    @State private var bannerService = BannerService.shared
    
    /// Binding to control the presentation state of the banner.
    @Binding var isPresented: Bool
    
    /// The type of banner to be displayed.
    let banner: BannerType

    /// Modifies the view to include banner presentation capabilities.
    ///
    /// - Parameter content: The content view being modified
    /// - Returns: A view with banner presentation functionality
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
    /// Adds a banner presentation capability to a view.
    ///
    /// This modifier allows any view to present banner notifications by providing:
    /// - A binding to control the presentation state
    /// - The type of banner to display
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether to show the banner
    ///   - banner: The type of banner to display when `isPresented` becomes true
    /// - Returns: A view that can present the specified banner
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
