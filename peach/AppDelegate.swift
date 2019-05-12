//
//  AppDelegate.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // 表示中のプロジェクトindex
    var projectIndex = 0
    // プロジェクトデータ
    var projects:[Project] = []
    // 選択されているプロジェクトのタスク（完了表示画面では 完了したタスク）
    var data: [Task] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        loadData()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        loadData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        saveData()
    }

    func saveData() {
        print("saveData")
        // 内部で保持するデータを保存する
        do {
            let json = JSONEncoder()
            UserDefaults.standard.set(projectIndex, forKey: "projectIndex")
            let projectsJson = try json.encode(projects)
            print(String(data: projectsJson, encoding: String.Encoding.utf8)!)
            UserDefaults.standard.set(projectsJson, forKey: "projects")
            UserDefaults.standard.synchronize()
        }
        catch {
            print(error)
        }
    }
    
    func loadData() {
        print("loadData")
        do {
            // 内部で保持するデータを読み込む
            projectIndex = UserDefaults.standard.integer(forKey: "projectIndex")
            
            if UserDefaults.standard.object(forKey: "projects") != nil {
                let projectsJson = UserDefaults.standard.object(forKey: "projects") as! Data
                print(String(data: projectsJson, encoding: String.Encoding.utf8)!)
                projects = try JSONDecoder().decode([Project].self, from: projectsJson)
                print(projects.description)
                data = projects[projectIndex].tasks
            }
        }
        catch {
            print(error)
        }
    }
}

