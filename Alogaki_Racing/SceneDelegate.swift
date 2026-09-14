//
//  SceneDelegate.swift
//  Alogaki_Racing
//
//  Created by Xenofon on 12/09/2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: BoardViewController())
        window.makeKeyAndVisible()
        self.window = window
    }
}
