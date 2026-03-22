//
//  PurchaseView.swift
//  week
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
                        subscriptionDetails
                        ForEach(products) { product in
                            SubscriptionButton(product: product, isLoading: isLoading) {
                                Task {
                                    await purchaseProduct(product)
                                }
                            }
                        }
                        subscriptionLegalNotice
                        termsAndPrivacy
                    }
                    .padding()
                }
                
                if isLoading {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
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
        }
    }
    
    private var subscriptionDetails: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("サブスクリプション内容")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            SubscriptionFeature(icon: "xmark.circle.fill", text: "すべての広告の削除")
            SubscriptionFeature(icon: "lock.open.fill", text: "グラフ機能のアンロック")
            Image("glaph")
                .resizable()
                .cornerRadius(4)
                .scaledToFit()
                .frame(height: 200)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.card)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var subscriptionLegalNotice: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "購入前にご確認ください"))
                .font(.headline)
            Text(String(localized: "サブスクリプションは Apple ID に請求されます。無料トライアル付きプランは、トライアル終了後に次回の購読期間の料金が自動で請求され、更新日の24時間前までに解約しない限り自動更新されます。各プランの価格と期間は上のボタンに表示しています。"))
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.card)
        .cornerRadius(10)
    }

    private var termsAndPrivacy: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 0)
            Button {
                Task {
                    await restorePurchases()
                }
            } label: {
                Text(String(localized: "購入を復元"))
            }
            .disabled(isLoading)
            Divider()
                .frame(height: 10)
            Link(destination: URL(string: privacyPolicyURL)!) {
                Text(String(localized: "プライバシーポリシー"))
            }
            Divider()
                .frame(height: 10)
            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                Text(String(localized: "利用規約（EULA）"))
            }
            Spacer(minLength: 0)
        }
        .font(.footnote)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
    
    private func loadProducts() async {
        do {
            var loadedProducts = try await Product.products(for: productIdList)
            // 月額プランを先頭に持ってくるようにソート
            loadedProducts.sort { product1, product2 in
                // 月額プランのIDを含む製品を優先（yearlyを含まないものを先に）
                !product1.id.contains("yearly") && product2.id.contains("yearly")
            }
            products = loadedProducts
        } catch {
            errorMessage = ErrorMessage(
                title: String(localized: "エラー"),
                message: String(format: String(localized: "製品の読み込みに失敗しました: %@"), error.localizedDescription)
            )
        }
    }
    
    private func purchaseProduct(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let transaction = try await purchase(product: product)
            sceneDelegate.enablePrivilege(productId: transaction.productID)
            await transaction.finish()
            await sceneDelegate.updateSubscriptionStatus()
            // 完了メッセージを表示
            showResultMessage(String(localized: "購入が完了しました。"), isError: false)
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
    
    private func showResultMessage(_ message: String, isError: Bool = false) {
        let title = isError ? String(localized: "エラー") : String(localized: "成功")
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
                showResultMessage(String(localized: "購入が復元されました。"), isError: false)
            } else {
                showResultMessage(String(localized: "復元可能な購入がありません。"), isError: true)
            }
        } catch {
            showResultMessage(String(format: String(localized: "購入の復元に失敗しました: %@"), error.localizedDescription), isError: true)
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

struct SubscriptionButton: View {
    let product: Product
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if product.id.contains("yearly") {
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 8) {
                        Text(trialHeadline)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(yearlyPricingText)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.accentColor.opacity(0.8), Color.accentColor
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .accent.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                    
                    Text("2ヶ月分お得")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Color.red
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .offset(x: -10, y: -5)
                }
            } else {
                // 月額プラン用の既存のデザイン
                VStack(spacing: 8) {
                    HStack {
                        Text("月間プランを開始")
                            .font(.headline)
                    }
                    Text(monthlyPricingText)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.card)
                .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    private var trialHeadline: String {
        if let offer = product.subscription?.introductoryOffer {
            return "\(offer.period.value)\(periodUnitString(offer.period.unit))の無料トライアルを開始"
        }
        return "年額プランを開始"
    }

    private var yearlyPricingText: String {
        if let offer = product.subscription?.introductoryOffer {
            return "\(offer.period.value)\(periodUnitString(offer.period.unit))無料。その後は\(product.displayPrice)/年が自動更新"
        }
        return "\(product.displayPrice)/年"
    }

    private var monthlyPricingText: String {
        "\(product.displayPrice)/月"
    }

    private func periodUnitString(_ unit: Product.SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day:
            return "日"
        case .week:
            return "週間"
        case .month:
            return "か月"
        case .year:
            return "年"
        @unknown default:
            return ""
        }
    }
}

#Preview {
    PurchaseView()
        .environmentObject(SceneDelegate())
}
