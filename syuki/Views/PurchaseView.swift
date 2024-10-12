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
            observeTransactionUpdates()
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
            VStack(alignment: .leading, spacing: 5) {
                Text(product.displayName)
                    .font(.headline)
                Text(product.displayPrice)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.card)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var subscriptionDetails: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("サブスクリプション内容")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            SubscriptionFeature(icon: "xmark.circle.fill", text: "広告の削除")
            
            Text("サブスクリプション期間")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 10)
            Text("選択したプランに応じて、1ヶ月または1年間の自動更新")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.card)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var termsAndPrivacy: some View {
        VStack {
            Link("プライバシーポリシー", destination: URL(string: "https://drive.google.com/file/d/1J3rL7Rr3k_HTctSGwDrCEgn8i-EH_RzY/view?usp=drive_link")!)
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
        let title = isError ? "エラー" : "成功"
        errorMessage = ErrorMessage(title: title, message: message)
    }
    
    private func getErrorMessage(error: Error) -> String {
        switch error {
        case SubscribeError.userCancelled:
            return "ユーザーによって購入がキャンセルされました"
        case SubscribeError.pending:
            return "購入が保留されています"
        case SubscribeError.productUnavailable:
            return "指定した商品が無効です"
        case SubscribeError.purchaseNotAllowed:
            return "OSの支払い機能が無効化されています"
        case SubscribeError.failedVerification:
            return "トランザクションデータの署名が不正です"
        default:
            return "不明なエラーが発生しました"
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
                    }
                } else if let expirationDate = transaction.expirationDate,
                          Date() < expirationDate, // 有効期限内
                          !transaction.isUpgraded // アップグレードされていない
                {
                    // 有効なサブスクリプションなのでproductIdに対応した特典を有効にする
                    await MainActor.run {
                        enablePrivilege(productId: transaction.productID)
                    }
                }

                await transaction.finish()
            }
        }
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
            return "ユーザーによって購入がキャンセルされました"
        case .pending:
            return "購入は保留中です"
        case .productUnavailable:
            return "指定した商品が無効です"
        case .purchaseNotAllowed:
            return "OSの支払い機能が無効化されています"
        case .failedVerification:
            return "トランザクションの検証に失敗しました"
        case .otherError:
            return "購入中に予期せぬエラーが発生しました"
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

#Preview {
    PurchaseView()
        .environmentObject(SceneDelegate())
}
