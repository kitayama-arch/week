//
//  SettingView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/10/01.
//

import SwiftUI

struct SettingView: View {
    @State private var showTutorial = false
    @State private var showPurchaseView = false
    // フィードバックとプライバシーポリシーのURLを定義
    private let feedbackURL: String
    private let privacyPolicyURL: String
    
    init() {
        // 言語に応じてURLを設定
        if Locale.current.language.languageCode?.identifier == "ja" {
            
            self.feedbackURL = "https://forms.gle/P37hSuQbonvAzck99"
            self.privacyPolicyURL = "https://drive.google.com/file/d/1J3rL7Rr3k_HTctSGwDrCEgn8i-EH_RzY/view?usp=sharing"
        } else {
            self.feedbackURL = "https://forms.gle/zXyNryof6r4DzmmLA"
            self.privacyPolicyURL = "https://drive.google.com/file/d/1mVGyMKKtu-DF2D9O2AsIMT8YcfHlvW7W/view?usp=sharing"
        }
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        premiumSection
                        
                        settingSection(title: "フィードバック") {
                            settingLink(icon: "square.and.pencil", text: "フィードバックを送信", url: feedbackURL)
                        }
                        
                        settingSection(title: "開発者情報") {
                            settingLink(icon: "globe", text: "開発者のウェブサイト", url: "https://example.com")
                            settingLink(icon: "bird", text: "開発者のTwitter", url: "https://twitter.com/developer")
                        }
                        
                        settingSection(title: "アプリについて") {
                            Button(action: {
                                if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                settingRow(icon: "star", text: "アプリを評価する")
                            }
                            
                            settingLink(icon: "lock.shield", text: "プライバシーポリシー", url: privacyPolicyURL)
                            
                            Button(action: {
                                showTutorial = true
                            }) {
                                settingRow(icon: "info.circle", text: "チュートリアルを表示")
                            }
                            
                            HStack {
                                Text("バージョン")
                                Spacer()
                                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "不明")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("設定")
        .foregroundColor(.primary)
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView()
        }
        .sheet(isPresented: $showPurchaseView) {
            PurchaseView()
        }
    }
    
    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("プレミアム機能")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack {
                Button(action: {
                    showPurchaseView = true
                }) {
                    HStack {
                        Image(systemName: "star.circle")
                            .frame(width: 30)
                        Text("プレミアムにアップグレード")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                    }
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(8)
            .shadow(color: .accent.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
        }
    }
    
    private func settingSection<Content: View>(title: LocalizedStringResource, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack {
                content()
            }
            .padding()
            .background(Color.card)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func settingLink(icon: String, text: LocalizedStringResource, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            settingRow(icon: icon, text: text)
        }
    }
    
    private func settingRow(icon: String, text: LocalizedStringResource) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(.primary) // この行を追加
            Text(text)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.footnote)
        }
        .padding(.vertical, 8)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
