// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces a banner. For example,
///
///     #banner(.success(message: "message"))
///
/// produces `BannerService.shared.addBanner(banner: .success(message: "message"))`.
@freestanding(expression)
public macro banner(_ value: BannerType) = #externalMacro(module: "AppBannersMacros", type: "BannerMacro")

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
@freestanding(expression)
public macro bannerAsync(_ value: BannerType) = #externalMacro(module: "AppBannersMacros", type: "BannerAsyncMacro")
