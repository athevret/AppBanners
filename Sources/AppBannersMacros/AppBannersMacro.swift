import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `banner` macro, which takes an expression
/// of type `BannerType` and produces the code to display a banner. For example:
///
///  `#banner(.success(message: "message"))`
///
/// will expand to:
///
///  `BannerService.shared.addBanner(banner: .success(message: "message"))`
///
public struct BannerMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        #if !NO_BANNER
        return """
            BannerService.shared.addBanner(banner: \(argument))
            """
        #else
        return ""
        #endif
    }
}

/// A macro that produces a banner in async context. For example,
///
///     #bannerAsync(.success(message: "message"))
///
/// produces:
///   `Task {`
///   `  await BannerService.shared.addBanner(
///   `    banner: .success(message: "message")`
///   `  )`
///   `}`
///
public struct BannerAsyncMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        #if !NO_BANNER
        return """
            _ = Task {
                await BannerService.shared.addBanner(
                    banner: \(argument)
                )
            }
            """
        #else
        return ""
        #endif
    }
}

@main
struct AppBannersPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BannerMacro.self,
        BannerAsyncMacro.self,
    ]
}
