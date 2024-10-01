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
        TutorialPage(image: "tutorial1", title: "ようこそ", description: "syukiアプリへようこそ！"),
        TutorialPage(image: "tutorial2", title: "タスク管理", description: "簡単にタスクを追加・管理できます。"),
        TutorialPage(image: "tutorial3", title: "進捗確認", description: "タスクの進捗を視覚的に確認できます。"),
        TutorialPage(image: "tutorial4", title: "始めましょう", description: "さあ、生産性を高めていきましょう！")
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
        .padding()
        .background(Color.background)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    TutorialView()
}
