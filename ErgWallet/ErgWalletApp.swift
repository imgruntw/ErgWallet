import SwiftUI

@main
struct ErgWalletApp: App {
    @UIApplicationDelegateAdaptor(Delegator.self) var delegator

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // this makes sure that we are setting the app to the app delegate as soon as the main view appears
                    delegator.app = self
                }
        }
    }
}
