//
//  MainTabView.swift
//  week
//
//  記録とアーカイブをボトムタブで切り替え
//

import SwiftUI
import UIKit

struct MainTabView: View {
    @EnvironmentObject private var sceneDelegate: SceneDelegate
    @State private var selectedTab = 0
    @State private var archiveResetToken = 0
    
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
                ArchiveView(resetToken: archiveResetToken)
                    .background(
                        TabBarReselectAccessor(targetIndex: 1) {
                            archiveResetToken += 1
                        }
                        .frame(width: 0, height: 0)
                    )
            }
            .tabItem {
                Label(String(localized: "アーカイブ"), systemImage: "archivebox")
            }
            .tag(1)
        }
        .environmentObject(sceneDelegate)
    }
}

private struct TabBarReselectAccessor: UIViewControllerRepresentable {
    let targetIndex: Int
    let onReselect: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(targetIndex: targetIndex, onReselect: onReselect)
    }

    func makeUIViewController(context: Context) -> ResolverViewController {
        let controller = ResolverViewController()
        controller.onResolve = { tabBarController in
            context.coordinator.attachIfNeeded(to: tabBarController)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: ResolverViewController, context: Context) {
        context.coordinator.targetIndex = targetIndex
        context.coordinator.onReselect = onReselect
        uiViewController.onResolve = { tabBarController in
            context.coordinator.attachIfNeeded(to: tabBarController)
        }
        uiViewController.resolveTabBarControllerIfNeeded()
    }

    final class Coordinator: NSObject, UITabBarControllerDelegate {
        var targetIndex: Int
        var onReselect: () -> Void
        weak var tabBarController: UITabBarController?
        weak var originalDelegate: UITabBarControllerDelegate?
        var lastSelectedIndex: Int?

        init(targetIndex: Int, onReselect: @escaping () -> Void) {
            self.targetIndex = targetIndex
            self.onReselect = onReselect
        }

        func attachIfNeeded(to tabBarController: UITabBarController) {
            guard self.tabBarController !== tabBarController else { return }
            self.tabBarController = tabBarController
            originalDelegate = tabBarController.delegate
            lastSelectedIndex = tabBarController.selectedIndex
            tabBarController.delegate = self
        }

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            let selectedIndex = tabBarController.selectedIndex
            if lastSelectedIndex == selectedIndex, selectedIndex == targetIndex {
                onReselect()
            }
            lastSelectedIndex = selectedIndex
            originalDelegate?.tabBarController?(tabBarController, didSelect: viewController)
        }
    }
}

private final class ResolverViewController: UIViewController {
    var onResolve: ((UITabBarController) -> Void)?

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        resolveTabBarControllerIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resolveTabBarControllerIfNeeded()
    }

    func resolveTabBarControllerIfNeeded() {
        if let tabBarController {
            onResolve?(tabBarController)
            return
        }

        var responder: UIResponder? = view
        while let current = responder {
            if let tabBarController = current as? UITabBarController {
                onResolve?(tabBarController)
                return
            }
            responder = current.next
        }

        if let tabBarController = view.window?.rootViewController?.findTabBarController() {
            onResolve?(tabBarController)
        }
    }
}

private extension UIViewController {
    func findTabBarController() -> UITabBarController? {
        if let tabBarController = self as? UITabBarController {
            return tabBarController
        }

        for child in children {
            if let tabBarController = child.findTabBarController() {
                return tabBarController
            }
        }

        if let presentedViewController {
            return presentedViewController.findTabBarController()
        }

        return nil
    }
}

#Preview {
    MainTabView()
        .environmentObject(SceneDelegate())
}
