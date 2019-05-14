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
    // 作業中・完了モード
    var mode: Int = 0
    // タイマー起動タスク
    var workTaskId : Int = -1
    // 開始時間
    var workStartTime : Date = Date()
    // タスクID発番
    var taskId : Int = 0
    
    //　プロジェクトカラー
    var projectColors:[ProjectColor] = []

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
        //loadData()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        //loadData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        saveData()
    }

    func saveData() {
        // 内部で保持するデータを保存する
        do {
            UserDefaults.standard.set(projectIndex, forKey: "projectIndex")
            UserDefaults.standard.set(mode, forKey: "mode")
            UserDefaults.standard.set(workTaskId, forKey: "workTaskId")
            UserDefaults.standard.set(workStartTime.timeIntervalSince1970, forKey: "workStartTime")
            UserDefaults.standard.set(taskId, forKey: "taskId")
            let json = JSONEncoder()
            let projectsJson = try json.encode(projects)
            //print(String(data: projectsJson, encoding: String.Encoding.utf8)!)
            UserDefaults.standard.set(projectsJson, forKey: "projects")
            UserDefaults.standard.synchronize()
        }
        catch {
            print(error)
        }
    }
    
    func loadData() {
        do {
            // 内部で保持するデータを読み込む
            projectIndex = UserDefaults.standard.integer(forKey: "projectIndex")
            mode = UserDefaults.standard.integer(forKey: "mode")
            workTaskId = UserDefaults.standard.integer(forKey: "workTaskId")
            if UserDefaults.standard.object(forKey: "workStartTime") != nil {
                workStartTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "workStartTime"))
            }
            taskId = UserDefaults.standard.integer(forKey: "taskId")
            if UserDefaults.standard.object(forKey: "projects") != nil {
                let projectsJson = UserDefaults.standard.object(forKey: "projects") as! Data
                //print(String(data: projectsJson, encoding: String.Encoding.utf8)!)
                projects = try JSONDecoder().decode([Project].self, from: projectsJson)
                //print(projects.description)
                data = projects[projectIndex].tasks
            }
            else {
                let project1 = Project()
                project1.project_id = 0
                project1.project_name="プロジェ１"
                project1.tasks = []
                projects.append(project1)
                
                var tasks : [Task] = []
                for i in 1...5 {
                    let task = Task()
                    task.task_id = getNextTaskId()
                    task.name = "タスク \(i)"
                    task.date = "05/12"
                    task.estimated_time = "1.0"
                    task.priority_flg = "0"
                    task.done_flg = "0"
                    task.duration = 0
                    task.label = "MTG"
                    task.project_id = 0
                    task.start_time = "\(8+i):00"
                    tasks.append(task)
                }
                projects[0].tasks = tasks
                projects[0].task_cnt = 5
                data = tasks
            }
        }
        catch {
            print(error)
        }
    }
    
    func getNextTaskId() -> Int {
        taskId += 1
        return taskId
    }
}

extension UIColor {
    class func hex (_ string : String, _ alpha : CGFloat) -> UIColor {
        let string_ = string.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: string_ as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            return UIColor.white;
        }
    }
}

let peachColor = UIColor.hex("#ffeeef", 1)
let peachDefaultColor = UIColor.hex("#ffc0cb", 1)
let taskBackground = UIColor.white
let swipeEditColor = UIColor.hex("#65c6bb", 1)
let swipeDeleteColor = UIColor.hex("#fa8072", 1)
let taskWorkingBGColor = UIColor.hex("#ffffe0", 1)

func convDuration(_ duration:Int) -> String {
    let hour = duration / 60
    let min  = duration % 60
    return "\(hour):" + String(format:"%02d",min)
}
