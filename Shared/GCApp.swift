//
//  GCApp.swift
//  Shared
//
//  Created by Yunfan Jiang on 11/20/21.
//

import SwiftUI
import Amplify

@main
struct GCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // initialize Amplify
    let _ = Backend.initialize()

    return true
}
