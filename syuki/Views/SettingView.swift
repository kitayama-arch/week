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
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
            
            VStack {
                Text("設定")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        settingSection(title: "フィードバック") {
                            settingLink(icon: "square.and.pencil", text: "フィードバックを送信", url: "https://forms.gle/your-google-form-url")
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
    }
    
    private func settingSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            VStack {
                content()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func settingLink(icon: String, text: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            settingRow(icon: icon, text: text)
        }
    }
    
    private func settingRow(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 30)
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
