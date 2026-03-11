import SwiftUI
import FirebaseCore
import GoogleSignIn
import Supabase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    // Handler legacy untuk iOS versi lama (tetap perlu buat backup)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct RimuruApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    DashboardView()
                } else {
                    LoginView()
                }
            }
            .onOpenURL { url in
                // Handler modern untuk URL Scheme Google Sign-In
                GIDSignIn.sharedInstance.handle(url)
            }
            .task {
                // Check session validitas pas app dibuka
                // Biar gak kena prank session expired tapi isLoggedIn masih true
                do {
                    let session = try await SupabaseService.shared.client.auth.session
                    if session.isExpired {
                        isLoggedIn = false
                    }
                } catch {
                    // Kalau error/gak ada session, ya suruh login lagi
                    isLoggedIn = false
                }
            }
        }
    }
}
