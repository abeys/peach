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
    // プロジェクトデータ
    var projects:[Project] = []
    // 選択されているプロジェクトのタスク（完了表示画面では 完了したタスク）
    var data: [Task] = []
    
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    var registVC:RegistTaskViewController? = nil
    
    let sidemenuViewController = SideMenuViewController()
    let contentViewController = UINavigationController(rootViewController: UIViewController())
    
    var isShowRegistTask: Bool = false
    
    private var isShownSidemenu: Bool {
        return sidemenuViewController.parent == self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 登録用画面の初期化
        // StoryBoardのインスタンスから、RegistTaskViewControllerを取得する
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        registVC = storyboard.instantiateViewController(withIdentifier: "registTask") as? RegistTaskViewController
        registVC!.delegate = self

        // テスト用データ
        var taskList:[Task] = []
        let task1 = Task()
        task1.project_id=1
        task1.name="001-タスク１"
        task1.date="2019-04-01"
        task1.start_time="00:00"
        task1.done_flg="0"
        task1.duration="01:00"
        task1.rabel="作業"
        taskList.append(task1)
        let project1 = Project()
        project1.project_id = 1
        project1.project_name="プロジェ１"
        project1.tasks = taskList
        projects.append(project1)

        // デフォルトで先頭のプロジェクト名を表示
        naviItem.title = projects[0].project_name

        sidemenuViewController.delegate = self
        tableView.reorder.delegate = self
        // delegateの初期化
        tableView.delegate = self
        tableView.dataSource = self
        // セルの初期化
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        var tasks : [Task] = []
        for i in 1...5 {
            let task = Task()
            task.task_id = i
            task.name = "タスク \(i)"
            task.date = "04/29"
            task.priority_flg = "0"
            task.done_flg = "0"
            task.duration = "20"
            task.project_id = 1
            task.start_time = "12:00"
            tasks.append(task)
        }
        data = tasks
    }
    
    // タスク追加実行
    @IBAction func tapAddTask(_ sender: Any) {
        showRegistTask(animated: true, index: -1)
    }
    
    // サイドメニュー
    @IBAction func tapSidemenu(_ sender: Any) {
        showSidemenu(animated: true)
    }
    
    func didRegistTask(index:Int, task: Task) {
        if index == -1 {
            data.append(task)
        }
        else {
            data.remove(at: index)
            data.insert(task, at: index)
        }
        tableView.reloadData()
        hideRegistTask(animated: true)
    }
    
    func didCancelRegistTask() {
        hideRegistTask(animated: true)
    }
    
    private func showRegistTask(contentAvailability: Bool = true, animated: Bool, index: Int) {
        if isShowRegistTask {
            return
        }
        isShowRegistTask = true
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
            task.duration = "0.5"
            task.task_id = 0 //TODO:idの振り方
            task.done_flg = "0"
            task.priority_flg = "0"
            registVC!.task = task
        }
        // ナビゲーションバーの高さを取得する
        let navHeight = naviBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height
        
        // 表示するRegistTaskの大きさ、位置を計算する
        var contentRect = registVC!.view!.bounds
        contentRect.size.height = CGFloat(registVC!.height)
        contentRect.origin.y = navHeight - contentRect.height
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
        isShowRegistTask = false
        // アニメーションで隠してから
        UIView.animate(withDuration: registVC!.duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.registVC!.view.center.y -= CGFloat(self.registVC!.height)
            self.registVC!.view.alpha = -0.5
        }, completion: {(fin) in
            //registView?.removeFromSuperview()
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

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = data[sourceIndexPath.row]
        data.remove(at: sourceIndexPath.row)
        data.insert(item, at: destinationIndexPath.row)
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
                cell.taskId.text = String(task.task_id)
                cell.date.text = task.date
                cell.taskName.text = task.name
                cell.star.tag = indexPath.row
                if task.priority_flg == "1" {
                    cell.star.setImage(UIImage(named: "star-yellow"), for: .normal)
                } else {
                    cell.star.setImage(UIImage(named: "star-white"), for: .normal)
                }
                cell.task = task
                cell.time.text = data[indexPath.row].start_time
                cell.workedTime.text = data[indexPath.row].duration
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
    
    func swipeContentsTap(content: String, index: Int) {
        switch content {
        case "edit":
            showRegistTask(animated: true, index: index)
        case "delete":
            data.remove(at: index)
            tableView.reloadData()
        default:
            print("zzzz")
        }
    }
    
    func changePriority(_ index: Int, _ priority: String) {
        data[index].priority_flg = priority
        if data[index].priority_flg == "1" {
            let item = data[index]
            data.remove(at: index)
            data.insert(item, at: 0)
        } else {
            let item = data[index]
            data.remove(at: index)
            data.append(item)
        }
        tableView.reloadData()
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
    
    func sidemenuViewController(_ sidemenuViewController: SideMenuViewController, didSelectItemAt indexPath: IndexPath) {
        naviItem.title = projects[indexPath.row].project_name
        hideSidemenu(animated: true)
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
}

