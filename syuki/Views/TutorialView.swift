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
        TutorialPage(image: "tutorial1", title: "ようこそ！Syukiの世界へ", description: "Syukiを使えば、「気づいたら一週間経ってた」がなくなります。"),
        TutorialPage(image: "tutorial2", title: "流れる日々を記録する", description: "毎日の出来事、アイデア、感情など、どんなことでも自由に書き留めましょう。思いついたときに、気軽に記録してみましょう。"),
        TutorialPage(image: "tutorial3", title: "少しでも前に進む", description: "週の目標を設定し、一歩ずつ前進しましょう。小さな進歩が大きな変化を生み出します。"),
        TutorialPage(image: "tutorial4", title: "過去の自分と比べる", description: "毎週日曜日は、Syukiで一週間を振り返る日。\n良かったこと、次週への改善策などをゆっくり整理し、自分の成長を確認しましょう。"),
        TutorialPage(image: "tutorial5", title: "いい生活はいい一週間から", description: "Syukiと共に、意識的な1週間を過ごしましょう。")
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
                        .padding(.horizontal, 20)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}

struct TutorialPage: Identifiable {
    let id = UUID()
    let image: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(height: 500)
            
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
