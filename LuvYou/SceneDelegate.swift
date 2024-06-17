//
//  SceneDelegate.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/15/24.
//

import UIKit
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
                
        self.window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
        let hasStartedBefore = UserDefaults.standard.bool(forKey: "hasStartedBefore")
        let documentID = UserDefaults.standard.string(forKey: "documentID")

        if hasStartedBefore && documentID != nil {
            // Firebase Firestore에서 document 존재 여부 확인 및 처리
            Firestore.firestore().collection("lovers").document(documentID!).getDocument { [weak self] (document, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching document: \(error)")
                    self.showAlertAndNavigateToInstallViewController()
                    return
                }
                
                guard let document = document, document.exists else {
                    print("Document does not exist")
                    self.showAlertAndNavigateToInstallViewController()
                    return
                }
                let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
                let gender = UserDefaults.standard.string(forKey: "myGender") ?? ""
                
                if gender != "여성" {
                    if let items = tabBarController?.tabBar.items {
                        for item in items {
                            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
                        }
                    }
                    tabBarController?.tabBar.tintColor = UIColor.your
                }
                self.window?.rootViewController = tabBarController
                self.window?.makeKeyAndVisible()
            }
        }
        else if hasStartedBefore != true {
            let installViewController = storyboard.instantiateViewController(withIdentifier: "InstallViewController")
            self.window?.rootViewController = installViewController
            self.window?.makeKeyAndVisible()
        }
    }

    func showAlertAndNavigateToInstallViewController() {
        let alertController = UIAlertController(title: nil, message: "당신의 연인이 LuvYou를 끝내셨습니다. 확인을 누르면 종료됩니다.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "종료", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            // InstallViewController로 이동
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let installViewController = storyboard.instantiateViewController(withIdentifier: "InstallViewController")
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            }
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
            self.window?.rootViewController = installViewController
            self.window?.makeKeyAndVisible()
        }))
        
        // 현재 루트 뷰 컨트롤러에서 경고 표시
        DispatchQueue.main.async {
            if let rootViewController = self.window?.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            } else {
                self.window?.rootViewController = UIViewController() // 임시 뷰 컨트롤러 설정
                self.window?.makeKeyAndVisible()
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
