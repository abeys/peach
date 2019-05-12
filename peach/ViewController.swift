//
//  ViewController.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit
import SwiftReorder

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, TaskCellDelegate, RegistTaskViewControllerDelegate {
    // 表示中のプロジェクトindex
    var projectIndex:Int {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.projectIndex
        }
        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.projectIndex = newValue
            // プロジェクトの選択変更時
            
        }
    }
    // プロジェクトデータ
    var projects:[Project] {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.projects
        }
        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.projects = newValue
        }
    }
    // 選択されているプロジェクトのタスク（完了表示画面では 完了したタスク）
    var data: [Task] {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.data
        }
        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.data = newValue
        }
    }
    
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var registVC:RegistTaskViewController? = nil
    
    let sidemenuViewController = SideMenuViewController()
    let contentViewController = UINavigationController(rootViewController: UIViewController())
    
    var isShowRegistTask: Bool {
        return registVC?.parent == self
    }
    
    private var isShownSidemenu: Bool {
        return sidemenuViewController.parent == self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewController did load.")
        // delegateの初期化
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reorder.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // 登録用画面の初期化
        // StoryBoardのインスタンスから、RegistTaskViewControllerを取得する
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        registVC = storyboard.instantiateViewController(withIdentifier: "registTask") as? RegistTaskViewController
        registVC!.delegate = self
        
        // サイドメニューのし初期化
        sidemenuViewController.delegate = self
        
        // 保存されているデータの読み込み
        //loadData()
        
        // テスト用データ(プロジェクト)
        
        if projects.count == 0 {
            let project1 = Project()
            project1.project_id = 0
            project1.project_name="プロジェ１"
            project1.tasks = []
            projects.append(project1)
        
            var tasks : [Task] = []
            for i in 1...5 {
                let task = Task()
                task.task_id = i
                task.name = "タスク \(i)"
                task.date = "05/12"
                task.estimated_time = "3h"
                task.priority_flg = "0"
                task.done_flg = "0"
                task.duration = "00:00"
                task.label = "MTG"
                task.project_id = 0
                task.start_time = "\(8+i):00"
                tasks.append(task)
            }
            projects[0].tasks = tasks
            data = tasks
        }
        
        // デフォルトで先頭のプロジェクト名を表示
        if projects.count > 0 {
            naviItem.title = projects[projectIndex].project_name
            // 全体の色をプロジェクトカラーに変更する
            
            //　ナビゲーションバーの背景色
            naviBar.barTintColor = .blue
            // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
            naviBar.tintColor = .white
            
            // ナビゲーションバーのテキストを変更する
            naviBar.titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            
            // 背景色
            self.view.backgroundColor = .blue
        }
        else {
            naviItem.title = ""
        }
    }
    
    // タスク追加実行
    @IBAction func tapAddTask(_ sender: Any) {
        showRegistTask(animated: true, index: -1)
    }
    
    // サイドメニュー
    @IBAction func tapSidemenu(_ sender: Any) {
        showSidemenu(animated: true)
    }
    
    // 登録画面で「done」を押した際に実行される
    func didRegistTask(index:Int, task: Task) {
        if index == -1 {
            data.append(task)
            projects[projectIndex].tasks.append(task)
            tableView.insertRows(at: [IndexPath(row: data.count-1, section: 0)], with: .automatic)
        }
        else {
            // 編集開始のプロジェクトと現在のプロジェクトが異なる場合
            if (task.project_id != projectIndex) {
                // 元のプロジェクトからタスクを削除
                projects[task.project_id].tasks.remove(at: index)
                // 現在のプロジェクトの末尾に追加
                data.append(task)
                projects[projectIndex].tasks.append(task)
                tableView.insertRows(at: [IndexPath(row: data.count-1, section: 0)], with: .automatic)
            }
            else {
                data.remove(at: index)
                data.insert(task, at: index)
                var tasks = projects[projectIndex].tasks
                tasks.remove(at: index)
                tasks.insert(task, at: index)
                tableView.reloadData()
            }
        }
        hideRegistTask(animated: true)
    }
    
    // 登録画面で[cancel」を押した際に実行される
    // 登録画面を非表示にするのみ
    func didCancelRegistTask() {
        hideRegistTask(animated: true)
    }
    
    // 登録画面を表示する
    private func showRegistTask(contentAvailability: Bool = true, animated: Bool, index: Int) {
        if isShowRegistTask {
            return
        }
        //isShowRegistTask = true
        // 新規登録、編集するタスクを準備する
        registVC!.index = index
        if index>=0 {
            registVC!.task = data[index]
        }
        else {
            // 新規追加するタスクの初期値をセットする
            let now = Date()
            let dtFormatter = DateFormatter()
            dtFormatter.dateFormat = "MM/dd"
            let cal = Calendar.current
            var hour = cal.component(.hour, from: now)
            var min  = cal.component(.minute, from: now)
            // 開始時間の調整
            if min > 30 {
                // 30分以降は、次の時間の正時に
                hour += 1
                min = 0
            }
            else {
                // そうでなければ、30分に
                min = 30
            }
            
            let task = Task()
            task.name = ""
            task.date = dtFormatter.string(from: Date())
            task.start_time = "\(hour):" + String(format:"%02d",min)
            task.estimated_time = "3.0h"
            task.duration = "0.5"
            task.task_id = 0 //TODO:idの振り方
            task.done_flg = "0"
            task.priority_flg = "0"
            task.project_id = projectIndex
            registVC!.task = task
        }
        // ナビゲーションバーの高さを取得する
        let navHeight = naviBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height
        // 表示するRegistTaskの大きさ、位置を計算する
        var contentRect = registVC!.view!.bounds
        // 縦幅を必要な分に縮める
        contentRect.size.height = CGFloat(registVC!.height)
        contentRect.origin.y = navHeight - contentRect.height
        // 横幅をテーブルビューの大きさに合わせる（６px）
        contentRect.size.width = view.frame.width - 12
        contentRect.origin.x = 6
        
        registVC!.view!.frame = contentRect
        registVC!.view!.autoresizingMask = .flexibleWidth
        
        addChild(registVC!)
        view.insertSubview(registVC!.view, aboveSubview: contentViewController.view)
        //naviBar.bringSubviewToFront(registVC!.view)
        registVC!.view.alpha = -0.5
        registVC!.didMove(toParent: self)
        
        // アニメーションで動かす
        UIView.animate(withDuration: registVC!.duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.registVC!.view.center.y += CGFloat(self.registVC!.height)
            self.registVC!.view.alpha = 1.0
        }, completion: nil)
        
        // TableViewは制約が貼ってあるので、制約を変更する
        view.setNeedsUpdateConstraints()
        tableViewTopConstraint.constant += CGFloat(registVC!.height)
        UIView.animate(withDuration: registVC!.duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hideRegistTask(animated: Bool) {
        if !isShowRegistTask {
            return
        }
        //isShowRegistTask = false
        // アニメーションで隠してから
        UIView.animate(withDuration: registVC!.duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.registVC!.view.center.y -= CGFloat(self.registVC!.height)
            self.registVC!.view.alpha = -0.5
        }, completion: {(fin) in
            // アニメーション完了後に表示を消す
            self.registVC!.willMove(toParent: nil)
            self.registVC!.removeFromParent()
            self.registVC!.view.removeFromSuperview()
        })
        // TableViewは制約が貼ってあるので、制約を変更する
        view.setNeedsUpdateConstraints()
        tableViewTopConstraint.constant -= CGFloat(registVC!.height)
        UIView.animate(withDuration: registVC!.duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func showSidemenu(contentAvailability: Bool = true, animated: Bool) {
        if isShownSidemenu {
            return
        }
        addChild(sidemenuViewController)
        sidemenuViewController.view.autoresizingMask = .flexibleHeight
        sidemenuViewController.view.frame = contentViewController.view.bounds
        view.insertSubview(sidemenuViewController.view, aboveSubview: contentViewController.view)
        sidemenuViewController.didMove(toParent: self)
        if contentAvailability {
            sidemenuViewController.showContentView(animated: animated)
        }
    }
    
    private func hideSidemenu(animated: Bool) {
        if !isShownSidemenu { return }
        
        sidemenuViewController.hideContentView(animated: animated, completion: { (_) in
            self.sidemenuViewController.willMove(toParent: nil)
            self.sidemenuViewController.removeFromParent()
            self.sidemenuViewController.view.removeFromSuperview()
        })
    }
    
    // タスクの順番変更
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = data[sourceIndexPath.row]
        let dest = data[destinationIndexPath.row]
        data.remove(at: sourceIndexPath.row)
        data.insert(item, at: destinationIndexPath.row)
        // projects.tasks 内の順番の入れ替え
        let srcIndex = projects[projectIndex].tasks.firstIndex(where: {task in return task.name == item.name })
        let desIndex = projects[projectIndex].tasks.firstIndex(where: {task in return task.name == dest.name })
        projects[projectIndex].tasks.remove(at: srcIndex!)
        projects[projectIndex].tasks.insert(item, at: desIndex!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    // プロジェクトに紐づくタスク一覧表示制御
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "taskcell", for: indexPath) as? TaskCell {
            let task = data[indexPath.row]
            cell.delegate = self
            let done_flg = data[indexPath.row].done_flg
            if done_flg == "0" {
                // TODO 配列の長さに応じたループ回数でないとエラーになる(現状は10回固定)
                cell.date.text = task.date
                cell.taskName.text = task.name
                cell.star.tag = indexPath.row
                if task.priority_flg == "1" {
                    cell.star.setImage(UIImage(named: "star02"), for: .normal)
                } else {
                    cell.star.setImage(UIImage(named: "star01"), for: .normal)
                }
                cell.task = task
                cell.date.text = data[indexPath.row].date + " " + data[indexPath.row].start_time
                cell.estimatedTime.text = data[indexPath.row].estimated_time
                cell.workedTime.text = data[indexPath.row].duration
                cell.label.text = data[indexPath.row].label

            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let swipeCellA = UITableViewRowAction(style: .default, title: "編集") { action, index in
            self.swipeContentsTap(content: "edit", index: index.row)
        }
        let swipeCellB = UITableViewRowAction(style: .default, title: "削除") { action, index in
            self.swipeContentsTap(content: "delete", index: index.row)
        }
        swipeCellA.backgroundColor = .blue
        swipeCellB.backgroundColor = .red
        return [swipeCellB, swipeCellA]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // スワイプコマンド（編集、削除）実行時に呼ばれる
    func swipeContentsTap(content: String, index: Int) {
        switch content {
        case "edit":
            showRegistTask(animated: true, index: index)
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.isHighlighted = true
        case "delete":
            data.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        default:
            print("zzzz")
        }
    }
    // 星（優先度）をタップされた際に実行される
    func changePriority(_ index: Int, _ priority: String) {
        data[index].priority_flg = priority
        var toIndex = data.count-1
        if data[index].priority_flg == "1" {
            let item = data[index]
            data.remove(at: index)
            data.insert(item, at: 0)
            toIndex = 0
        } else {
            let item = data[index]
            data.remove(at: index)
            data.append(item)
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.beginUpdates()
            self.tableView.moveRow(at: IndexPath(row: index, section: 0), to: IndexPath(row: toIndex, section: 0))
            self.tableView.endUpdates()
        }, completion: {finish in
            self.tableView.reloadRows(at: [IndexPath(row: toIndex, section: 0)], with: .automatic)
        })
    }
}

// セルの並び替え
extension ViewController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update data model
        let item = data[sourceIndexPath.row]
        data.remove(at: sourceIndexPath.row)
        data.insert(item, at: destinationIndexPath.row)
    }
}

// スライドメニューバー処理
extension ViewController: SidemenuViewControllerDelegate {
    func parentViewControllerForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> UIViewController {
        return self
    }
    
    func shouldPresentForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> Bool {
        /* You can specify sidemenu availability */
        return true
    }
    
    func sidemenuViewControllerDidRequestShowing(_ sidemenuViewController: SideMenuViewController, contentAvailability: Bool, animated: Bool) {
        showSidemenu(contentAvailability: contentAvailability, animated: animated)
    }
    
    func sidemenuViewControllerDidRequestHiding(_ sidemenuViewController: SideMenuViewController, animated: Bool) {
        hideSidemenu(animated: animated)
    }
    // サイドメニューでプロジェクトを選択した際に呼ばれる
    func sidemenuViewController(_ sidemenuViewController: SideMenuViewController, didSelectItemAt indexPath: IndexPath) {
        naviItem.title = projects[0].project_name
        hideSidemenu(animated: true)
        
        projectIndex = 0
        data = []
        for task in projects[projectIndex].tasks {
            // TODO:画面の表示モードによって切り替えるべき
            if task.done_flg == "0" {
                data.append(task)
            }
        }
        tableView.reloadData()
    }
    
    func getProjects() -> [Project] {
        return projects
    }
    
    func setProjectName(projectName: String){
        naviItem.title = projectName
    }
    
    func appendProject(project: Project){
        projects.append(project)
    }

    func selectProject(index: Int){
        let proj = projects[index]
        projects.remove(at: index)
        projects.insert(proj, at: 0)
    }
}

