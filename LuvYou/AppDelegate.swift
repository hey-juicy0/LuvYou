//
//  AppDelegate.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/15/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var documentID = UserDefaults.standard.string(forKey: "documentID")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // Override point for customization after application launch.
        
        let fontNames = [
            "PretendardVariable-Regular",
            "PretendardVariable-Thin",
            "PretendardVariable-ExtraLight",
            "PretendardVariable-Light",
            "PretendardVariable-Medium",
            "PretendardVariable-SemiBold",
            "PretendardVariable-Bold",
            "PretendardVariable-ExtraBold",
            "PretendardVariable-Black"
        ]
        if let documentID = UserDefaults.standard.string(forKey: "documentID") {
                self.documentID = documentID
                checkDocumentExistence()
            }
        return true
    }

    
    func checkDocumentExistence() {
        Firestore.firestore().collection("lovers").document(documentID!).getDocument { (document, error) in
                if let error = error {
                    print("Error getting document: \(error)")
                    return
                }
                
                if document == nil || !document!.exists {
                    DispatchQueue.main.async {
                        self.showAlertAndNavigateToInstallViewController()
                    }
                }
            }
        }

        func showAlertAndNavigateToInstallViewController() {
            let alertController = UIAlertController(title: nil, message: "당신의 연인이 LuvYou를 끝내셨습니다. 확인을 누르면 초기화면으로 돌아갑니다.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                // InstallViewController로 이동합니다.
                self.navigateToInstallViewController()
            }))
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }

        func navigateToInstallViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let installViewController = storyboard.instantiateViewController(withIdentifier: "InstallViewController")
            //                if let bundleIdentifier = Bundle.main.bundleIdentifier {
            //                    UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            //                }
            self.window?.rootViewController = installViewController
        }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
