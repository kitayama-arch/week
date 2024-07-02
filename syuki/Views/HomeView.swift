//
//  ContentView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                //                Color.gray
                //                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    Text("今週の目標")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    GoalCardView()
                        .padding(.bottom)
                    
                    Text("思考記録")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    ThoughtCardView()
                    // ここではまだ思考カードは1枚のみ
                        .padding(.bottom)
                    
                    Spacer()
                }
            }
        }
    }
}
#Preview {
    HomeView()
}
