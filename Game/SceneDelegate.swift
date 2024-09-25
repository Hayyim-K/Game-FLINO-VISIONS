//
//  SceneDelegate.swift
//  Pocer Crush
//
//  Created by Александр on 15.09.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        print("""


HERE!!! \(#function)



""")
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let gubas = UINavigationController(rootViewController: UpdateLevelsOnOldVersion())
        gubas.navigationBar.isHidden = true
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = gubas
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
    
}


