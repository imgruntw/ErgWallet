import SwiftUI
import UserNotifications

class Delegator: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var app: ErgWalletApp?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // This is where we register this device to recieve push notifications from Apple
        // All this function does is register the device with APNs, it doesn't set up push notifications by itself
        application.registerForRemoteNotifications()
        
        // Setting the notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Once the device is registered for push notifications Apple will send the token to our app and it will be available here
        // This is also where we will forward the token to our push server
        // If you want to see a string version of your token, you can use the following code to print it out
        let stringifiedToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("stringifiedToken: \(stringifiedToken)\n")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // This function lets us do something when the user interacts with a notification
        // like log that they clicked it, or navigate to a specific screen
        print("Got notification title: ", response.notification.request.content.title)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // This function allows us to view notifications in the app even with it in the foreground
        // These options are the options that will be used when displaying a notification with the app in the foreground
        // for example, we will be able to display a badge on the app a banner alert will appear and we could play a sound
        completionHandler([.badge, .banner, .list, .sound])
    }
}
