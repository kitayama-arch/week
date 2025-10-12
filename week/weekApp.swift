//
//  weekApp.swift
//  week
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
       #if DEBUG
       FirebaseApp.configure()
       #endif
      print("FirebaseApp count: \(FirebaseApp.allApps?.count ?? 0)")
      GADMobileAds.sharedInstance().start(completionHandler: nil)
      return true
  }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    @Published var isPremium = false
    @Published var currentPlan: String = NSLocalizedString("無料プラン", comment: "Free plan")
    
    override init() {
        super.init()
        print("SceneDelegate: 初期化")
        observeTransactionUpdates()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("SceneDelegate: フォアグラウンドに入ります")
        Task {
            await updateSubscriptionStatus()
        }
    }
    
    func updateSubscriptionStatus() async {
        print("SceneDelegate: サブスクリプション状態を更新中")
        var validSubscription: StoreKit.Transaction?
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = verificationResult,
               transaction.productType == .autoRenewable &&
               !transaction.isUpgraded &&
               transaction.expirationDate != nil &&
               transaction.expirationDate! > Date() {
                validSubscription = transaction
                print("SceneDelegate: 有効なサブスクリプションを見つけました - \(transaction.productID)")
                break
            }
        }

        if let productId = validSubscription?.productID {
            print("SceneDelegate: 特典を有効化 - \(productId)")
            enablePrivilege(productId: productId)
            isPremium = true
            currentPlan = getPlanName(for: productId)
        } else {
            print("SceneDelegate: 有効なサブスクリプションが見つかりません。特典を無効化します")
            disablePrivilege()
            isPremium = false
            currentPlan = NSLocalizedString("無料プラン", comment: "Free plan")
        }
        print("SceneDelegate: 現在の状態 - isPremium: \(isPremium), currentPlan: \(currentPlan)")
    }
    
    public func enablePrivilege(productId: String) {
        print("SceneDelegate: 特典を有効化: \(productId)")
        UserDefaults.standard.set(true, forKey: "isPremium")
        isPremium = true
        currentPlan = getPlanName(for: productId)
    }
    
    private func disablePrivilege() {
        print("SceneDelegate: 特典を無効化")
        UserDefaults.standard.set(false, forKey: "isPremium")
    }
    
    private func getPlanName(for productId: String) -> String {
        switch productId {
        case "com.gmail.iura.smh.week.monthly":
            return NSLocalizedString("月額プラン", comment: "Monthly plan")
        case "com.gmail.iura.smh.week.yearly":
            return NSLocalizedString("年額プラン", comment: "Yearly plan")
        default:
            return NSLocalizedString("不明なプラン", comment: "Unknown plan")
        }
    }
    
    private func observeTransactionUpdates() {
        print("SceneDelegate: トランザクション更新の監視を開始")
        Task(priority: .background) {
            for await verificationResult in StoreKit.Transaction.updates {
                guard case .verified(let transaction) = verificationResult else {
                    print("SceneDelegate: 検証に失敗したトランザクション")
                    continue
                }

                await MainActor.run {
                    print("SceneDelegate: 新しいトランザクション - \(transaction.productID)")
                    if transaction.revocationDate != nil {
                        print("SceneDelegate: 払い戻しされたトランザクション")
                        disablePrivilege()
                        isPremium = false
                        currentPlan = NSLocalizedString("無料プラン", comment: "Free plan")
                    } else if let expirationDate = transaction.expirationDate {
                        if Date() < expirationDate {
                            if !transaction.isUpgraded {
                                print("SceneDelegate: 有効なサブスクリプション - \(transaction.productID)")
                                enablePrivilege(productId: transaction.productID)
                                isPremium = true
                                currentPlan = getPlanName(for: transaction.productID)
                            } else {
                                print("SceneDelegate: アップグレードされたトランザクション")
                            }
                        } else {
                            print("SceneDelegate: 期限切れのトランザクション")
                            disablePrivilege()
                            isPremium = false
                            currentPlan = NSLocalizedString("無料プラン", comment: "Free plan")
                        }
                    } else {
                        print("SceneDelegate: 有効期限のないトランザクション")
                    }
                    print("SceneDelegate: 更新後の状態 - isPremium: \(isPremium), currentPlan: \(currentPlan)")
                }

                await transaction.finish()
                print("SceneDelegate: トランザクション処理完了")
            }
        }
    }
}

@main
struct weekApp: App {
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
