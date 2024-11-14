import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(AppBannersMacros)
import AppBannersMacros

let testMacros: [String: Macro.Type] = [
    "banner": BannerMacro.self,
    "bannerAsync": BannerAsyncMacro.self,
]
#endif

final class AppBannersTests: XCTestCase {
    func testBannerMacro() throws {
        #if canImport(AppBannersMacros)
        assertMacroExpansion(
            """
            #banner(.success(title: "Title", message: "Message"))
            """,
            expandedSource: """
            BannerService.shared.addBanner(banner: .success(title: "Title", message: "Message"))
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testBannerAsyncMacro() throws {
        #if canImport(AppBannersMacros)
        assertMacroExpansion(
            """
            #bannerAsync(
                .success(
                    title: "Title",
                    message: "Message"
                )
            )
            """,
            expandedSource: """
                _ = Task {
                    await BannerService.shared.addBanner(
                        banner:
                    .success(
                        title: "Title",
                        message: "Message"
                    )
                    )
                }
                """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
