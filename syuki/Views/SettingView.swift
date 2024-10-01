//
//  SettingView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/10/01.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        settingSection(title: "フィードバック") {
                            settingLink(icon: "square.and.pencil", text: "フィードバックを送信", urlKey: "feedback_form_url")
                        }
                        
                        settingSection(title: "開発者情報") {
                            settingLink(icon: "globe", text: "開発者のウェブサイト", urlKey: "developer_website_url")
                            settingLink(icon: "bird", text: "開発者のTwitter", urlKey: "developer_twitter_url")
                        }
                        
                        settingSection(title: "アプリについて") {
                            Button(action: {
                                if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                settingRow(icon: "star", text: "アプリを評価する")
                            }
                            
                            settingLink(icon: "lock.shield", text: "プライバシーポリシー", urlKey: "privacy_policy_url")
                            
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
    
    private func settingLink(icon: String, text: LocalizedStringResource, urlKey: String) -> some View {
        Link(destination: URL(string: NSLocalizedString(urlKey, comment: ""))!) {
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
