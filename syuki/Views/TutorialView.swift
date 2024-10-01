//
//  TutorialView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/10/01.
//

import SwiftUI

struct TutorialView: View {
    @State private var currentPage = 0
    @Environment(\.dismiss) private var dismiss
    
    let tutorialPages = [
        TutorialPage(image: "tutorial1", title: "ようこそ！Syukiの世界へ", description: "Syukiは、あなたのペースで、無理なく続けられる自己成長サポートアプリです。シンプルな操作で、日記が続かない方でも無理なく続けられます。"),
        TutorialPage(image: "tutorial2", title: "毎日記録する必要はありません。", description: "毎日の出来事、アイデア、感情など、どんなことでも自由に書き留めましょう。思いついたときに、気軽に記録してみましょう。"),
        TutorialPage(image: "tutorial3", title: "週の目標で、一歩ずつ前進", description: "週の始めに目標を設定することで、目指す方向が明確になり、行動が変わります。達成したいこと、チャレンジしたいことを、具体的に書き出してみましょう。"),
        TutorialPage(image: "tutorial4", title: "日曜日に一週間を振り返る", description: "毎週日曜日は、Syukiで一週間を振り返る日。\n良かったこと、反省点、次週への改善策などを整理することで、着実に成長できます。"),
        TutorialPage(image: "tutorial5", title: "いい生活はいい一週間から。", description: "さあ、始めましょう")
    ]
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<tutorialPages.count, id: \.self) { index in
                        TutorialPageView(page: tutorialPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack {
                    ForEach(0..<tutorialPages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.primary : Color.secondary)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                Button(action: {
                    if currentPage < tutorialPages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        dismiss()
                    }
                }) {
                    Text(currentPage < tutorialPages.count - 1 ? "次へ" : "始める")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}

struct TutorialPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            
            Text(page.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    TutorialView()
}
