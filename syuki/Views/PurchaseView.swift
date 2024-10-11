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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        subscriptionPlans
                        subscriptionDetails
                        termsAndPrivacy
                    }
                    .padding()
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
        }
    }
    
    private var subscriptionPlans: some View {
        VStack(spacing: 15) {
            planButton(title: "月額プラン", price: "¥500/月", action: {})
            planButton(title: "年額プラン", price: "¥5,000/年", action: {})
        }
    }
    
    private func planButton(title: LocalizedStringKey, price: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(price)
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

#Preview {
    PurchaseView()
}
