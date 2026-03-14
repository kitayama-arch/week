//
//  MainTabView.swift
//  week
//
//  記録とアーカイブをボトムタブで切り替え
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(String(localized: "記録する"), systemImage: "square.and.pencil")
            }
            .tag(0)
            
            NavigationStack {
                ArchiveView()
            }
            .tabItem {
                Label(String(localized: "アーカイブ"), systemImage: "archivebox")
            }
            .tag(1)
        }
        .environmentObject(sceneDelegate)
    }
}

#Preview {
    MainTabView()
        .environmentObject(SceneDelegate())
}
