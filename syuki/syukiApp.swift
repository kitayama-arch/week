//
//  syukiApp.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds

class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      FirebaseApp.configure()
      GADMobileAds.sharedInstance().start(completionHandler: nil)
      return true
  }
}

@main
struct syukiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showTutorial = false
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onAppear {
                    if !hasSeenTutorial {
                        showTutorial = true
                    }
                }
                .fullScreenCover(isPresented: $showTutorial) {
                    TutorialView()
                        .onDisappear {
                            hasSeenTutorial = true
                        }
                }
        }
    }
}
