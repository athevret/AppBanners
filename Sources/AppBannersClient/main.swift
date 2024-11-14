import AppBanners

final class AppBannersExample {
    @MainActor public func example() {
        #banner(.success(title: "Title", message: "Message"))
    }

    public func asyncExample() {
        #bannerAsync(
            .success(
                title: "Title",
                message: "Message"
            )
        )
    }
}
