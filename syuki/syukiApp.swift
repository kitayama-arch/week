//
//  syukiApp.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds
import StoreKit

class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      FirebaseApp.configure()
      GADMobileAds.sharedInstance().start(completionHandler: nil)
      return true
  }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    @Published var isPremium = false
    @Published var currentPlan: String = "無料プラン"
    
    override init() {
        super.init()
        observeTransactionUpdates()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        Task {
            await updateSubscriptionStatus()
        }
    }
    
    func updateSubscriptionStatus() async {
        var validSubscription: StoreKit.Transaction?
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = verificationResult,
               transaction.productType == .autoRenewable && !transaction.isUpgraded {
                validSubscription = transaction
            }
        }

        if let productId = validSubscription?.productID {
            // 特典を付与
            enablePrivilege(productId: productId)
            isPremium = true
            currentPlan = getPlanName(for: productId)
        } else {
            // 特典を削除
            disablePrivilege()
            isPremium = false
            currentPlan = "無料プラン"
        }
    }
    
    private func enablePrivilege(productId: String) {
        print("特典を有効化: \(productId)")
        UserDefaults.standard.set(true, forKey: "isPremium")
    }
    
    private func disablePrivilege() {
        print("特典を無効化")
        UserDefaults.standard.set(false, forKey: "isPremium")
    }
    
    private func getPlanName(for productId: String) -> String {
        switch productId {
        case "com.gmail.iura.smh.week.monthly":
            return "月額プラン"
        case "com.gmail.iura.smh.week.yearly":
            return "年額プラン"
        default:
            return "不明なプラン"
        }
    }
    
    private func observeTransactionUpdates() {
        Task(priority: .background) {
            for await verificationResult in StoreKit.Transaction.updates {
                guard case .verified(let transaction) = verificationResult else {
                    continue
                }

                if transaction.revocationDate != nil {
                    // 払い戻しされてるので特典削除
                    await MainActor.run {
                        disablePrivilege()
                        isPremium = false
                        currentPlan = "無料プラン"
                    }
                } else if let expirationDate = transaction.expirationDate,
                          Date() < expirationDate, // 有効期限内
                          !transaction.isUpgraded // アップグレードされていない
                {
                    // 有効なサブスクリプションなのでproductIdに対応した特典を有効にする
                    await MainActor.run {
                        enablePrivilege(productId: transaction.productID)
                        isPremium = true
                        currentPlan = getPlanName(for: transaction.productID)
                    }
                }

                await transaction.finish()
            }
        }
    }
}

@main
struct syukiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showTutorial = false
    @StateObject private var sceneDelegate = SceneDelegate()
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isPremium") private var isPremium = false
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(sceneDelegate)  // この行を追加
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
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        Task {
                            await sceneDelegate.updateSubscriptionStatus()
                            isPremium = sceneDelegate.isPremium
                        }
                    }
                }
        }
    }
}
