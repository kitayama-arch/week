//
//  PurchaseView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/10/10.
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    let productIdList = [
        "com.gmail.iura.smh.week.monthly",
        "com.gmail.iura.smh.week.yearly",
    ]
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: ErrorMessage?
    private let privacyPolicyURL: String
    
    init() {
        // 言語に応じてURLを設定
        if Locale.current.language.languageCode?.identifier == "ja" {
            self.privacyPolicyURL = "https://drive.google.com/file/d/1J3rL7Rr3k_HTctSGwDrCEgn8i-EH_RzY/view?usp=sharing"
        } else {
            self.privacyPolicyURL = "https://drive.google.com/file/d/1mVGyMKKtu-DF2D9O2AsIMT8YcfHlvW7W/view?usp=sharing"
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        currentPlanView
                        subscriptionPlans
                        subscriptionDetails
                        restoreButton
                        termsAndPrivacy
                    }
                    .padding()
                }
                
                if isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("プレミアムプラン")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
            .alert(item: $errorMessage) { error in
                Alert(title: Text(error.title), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
        .task {
            await loadProducts()
        }
    }
    
    private var currentPlanView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("現在のプラン")
                .font(.headline)
            Text(sceneDelegate.currentPlan)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.card)
        .cornerRadius(10)
    }
    
    private var subscriptionPlans: some View {
        VStack(spacing: 15) {
            ForEach(products) { product in
                planButton(product: product)
            }
        }
    }
    
    private func planButton(product: Product) -> some View {
        Button(action: {
            Task {
                await purchaseProduct(product)
            }
        }) {
            ProductView(product: product)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.card)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor, lineWidth: 2)
                )
        }
    }
    
    private var subscriptionDetails: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("サブスクリプション内容")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            SubscriptionFeature(icon: "xmark.circle.fill", text: "広告の削除")
            SubscriptionFeature(icon: "lock.open.fill", text: "グラフ機能のアンロック")
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.card)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var restoreButton: some View {
        Button("購入を復元") {
            Task {
                await restorePurchases()
            }
        }
        .font(.headline)
        .foregroundColor(.blue)
    }

    private var termsAndPrivacy: some View {
        VStack {
            Link("プライバシーポリシー", destination: URL(string: privacyPolicyURL)!)
            Link("利用規約", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
        .font(.footnote)
        .foregroundColor(.blue)
    }
    
    private func loadProducts() async {
        do {
            products = try await Product.products(for: productIdList)
        } catch {
            errorMessage = ErrorMessage(title: "エラー", message: "製品の読み込みに失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func purchaseProduct(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let transaction = try await purchase(product: product)
            // productIdに対応した特典を有効にする
            enablePrivilege(productId: transaction.productID)
            await transaction.finish()
            // 完了メッセージを表示
            showResultMessage("購入が完了しました。", isError: false)
        } catch {
            // エラーメッセージを表示
            let errorMessage = getErrorMessage(error: error)
            showResultMessage(errorMessage, isError: true)
        }
    }
    
    private func purchase(product: Product) async throws -> StoreKit.Transaction {
        // Product.PurchaseResultの取得
        let purchaseResult: Product.PurchaseResult
        do {
            purchaseResult = try await product.purchase()
        } catch Product.PurchaseError.productUnavailable {
            throw SubscribeError.productUnavailable
        } catch Product.PurchaseError.purchaseNotAllowed {
            throw SubscribeError.purchaseNotAllowed
        } catch {
            throw SubscribeError.otherError
        }

        // VerificationResultの取得
        let verificationResult: VerificationResult<StoreKit.Transaction>
        switch purchaseResult {
        case .success(let result):
            verificationResult = result
        case .userCancelled:
            throw SubscribeError.userCancelled
        case .pending:
            throw SubscribeError.pending
        @unknown default:
            throw SubscribeError.otherError
        }

        // Transactionの取得
        switch verificationResult {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw SubscribeError.failedVerification
        }
    }
    
    private func enablePrivilege(productId: String) {
        // ここで特典を有効にする処理を実装
        // 例: UserDefaultsに保存したり、サーバーに通知したりする
        print("特典を有効化: \(productId)")
        UserDefaults.standard.set(true, forKey: "isPremium")
    }
    
    private func disablePrivilege() {
        // ここで特典を無効にする処理を実装
        // 例: UserDefaultsから削除したり、サーバーに通知したりする
        print("特典を無効化")
        UserDefaults.standard.set(false, forKey: "isPremium")
    }
    
    private func showResultMessage(_ message: String, isError: Bool = false) {
        let title = isError ? "エラ��" : "成功"
        errorMessage = ErrorMessage(title: title, message: message)
    }
    
    private func getErrorMessage(error: Error) -> String {
        switch error {
        case SubscribeError.userCancelled:
            return NSLocalizedString("ユーザーによって購入がキャンセルされました", comment: "User cancelled purchase error")
        case SubscribeError.pending:
            return NSLocalizedString("購入が保留されています", comment: "Purchase pending error")
        case SubscribeError.productUnavailable:
            return NSLocalizedString("指定した商品が無効です", comment: "Product unavailable error")
        case SubscribeError.purchaseNotAllowed:
            return NSLocalizedString("OSの支払い機能が無効化されています", comment: "Purchase not allowed error")
        case SubscribeError.failedVerification:
            return NSLocalizedString("トランザクションデータの署名が不正です", comment: "Failed verification error")
        default:
            return NSLocalizedString("不明なエラーが発生しました", comment: "Unknown error")
        }
    }
    
    private func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()

            var restoredSubscription = false
            for productId in productIdList {
                let verificationResult = await Transaction.currentEntitlement(for: productId)
                if case .verified(let transaction) = verificationResult {
                    if transaction.revocationDate == nil,
                       let expirationDate = transaction.expirationDate,
                       Date() < expirationDate {
                        restoredSubscription = true
                        sceneDelegate.enablePrivilege(productId: productId)
                        break
                    }
                }
            }

            if restoredSubscription {
                showResultMessage("購入が復元されました。", isError: false)
            } else {
                showResultMessage("復元可能な購入がありません。", isError: true)
            }
        } catch {
            showResultMessage("購入の復元に失敗しました: \(error.localizedDescription)", isError: true)
        }

        // 購読状態を更新
        await sceneDelegate.updateSubscriptionStatus()
    }
}

enum SubscribeError: LocalizedError {
    case userCancelled
    case pending
    case productUnavailable
    case purchaseNotAllowed
    case failedVerification
    case otherError

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return NSLocalizedString("ユーザーによって購入がキャンセルされました", comment: "User cancelled purchase error")
        case .pending:
            return NSLocalizedString("購入は保留中です", comment: "Purchase pending error")
        case .productUnavailable:
            return NSLocalizedString("指定した商品が無効です", comment: "Product unavailable error")
        case .purchaseNotAllowed:
            return NSLocalizedString("OSの支払い機能が無効化されています", comment: "Purchase not allowed error")
        case .failedVerification:
            return NSLocalizedString("トランザクションの検証に失敗しました", comment: "Failed verification error")
        case .otherError:
            return NSLocalizedString("購入中に予期せぬエラーが発生しました", comment: "Other purchase error")
        }
    }
}

struct SubscriptionFeature: View {
    let icon: String
    let text: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.system(size: 22))
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct ProductView: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.displayName)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(product.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(product.displayPrice)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if let period = product.subscription?.subscriptionPeriod {
                    Text("\(period.value) \(periodUnitString(period.unit))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func periodUnitString(_ unit: Product.SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day:
            return NSLocalizedString("日", comment: "Subscription period unit: day")
        case .week:
            return NSLocalizedString("週間", comment: "Subscription period unit: week")
        case .month:
            return NSLocalizedString("ヶ月", comment: "Subscription period unit: month")
        case .year:
            return NSLocalizedString("年", comment: "Subscription period unit: year")
        @unknown default:
            return NSLocalizedString("", comment: "Unknown subscription period unit")
        }
    }
}

#Preview {
    PurchaseView()
        .environmentObject(SceneDelegate())
}
