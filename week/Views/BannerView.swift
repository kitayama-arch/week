//
//  BannerView.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/10/01.
//

import SwiftUI
import UIKit
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = "ca-app-pub-9220556303143367/2661823011"
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        _ = windowScene?.keyWindow?.rootViewController
        banner.load(GADRequest())
        return banner // 最終的にインスタンスを返す
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
      // 特にないのでメソッドだけ用意
    }
}
