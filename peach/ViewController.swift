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
    // 一覧表示モード(作業中タスク一覧/完了タスク一覧)
    var mode:Int {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.mode
        }
        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.mode = newValue
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
    
    // プロジェクトカラー
    var projectColors: [ProjectColor] {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.projectColors
        }
        set {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.projectColors = newValue
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
    
    func initProjectColor() {
        let p0 = ProjectColor()
        p0.primary = UIColor.hex("#ffc0cb",1)
        p0.secondary = UIColor.hex("#ffe0eb",1)
        p0.textColor = UIColor.black
        let p1 = ProjectColor()
        p1.primary = UIColor.hex("#ffa500",1)
        p1.secondary = UIColor.hex("#ffc530",1)
        p1.textColor = UIColor.black
        let p2 = ProjectColor()
        p2.primary = UIColor.hex("#adff2f",1)
        p2.secondary = UIColor.hex("#cdff4f",1)
        p2.textColor = UIColor.black
        let p3 = ProjectColor()
        p3.primary = UIColor.hex("#87cdfa",1)
        p3.secondary = UIColor.hex("#a7edfa",1)
        p3.textColor = UIColor.black
        let p4 = ProjectColor()
        p4.primary = UIColor.hex("",1)
        p4.secondary = UIColor.hex("",1)
        p4.textColor = UIColor.black
        let p5 = ProjectColor()
        p5.primary = UIColor.hex("",1)
        p5.secondary = UIColor.hex("",1)
        p5.textColor = UIColor.black
        
        projectColors = [p0,p1,p2,p3,p4,p5]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewController did load.")
        
        // プロジェクトカラーの初期化
        initProjectColor()
        
        // 下線を消す処理
        naviBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        naviBar.shadowImage = UIImage()
        
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
            projects[0].task_cnt = 5
            data = tasks
        }
        
        // デフォルトで先頭のプロジェクト名を表示
        if projects.count > 0 {
            naviItem.title = projects[projectIndex].project_name
            // 全体の色をプロジェクトカラーに変更する
            let color = projectColors[projects[projectIndex].color_index]
            //　ナビゲーションバーの背景色
            naviBar.barTintColor = color.primary
            // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
            naviBar.tintColor = color.textColor
            
            // ナビゲーションバーのテキストを変更する
            naviBar.titleTextAttributes = [
                .foregroundColor: color.textColor
            ]
            
            // 背景色
            self.view.backgroundColor = color.primary
        }
        else {
            naviItem.title = ""
        }
    }
    
    // 完了一覧表示
    @IBAction func dispDone(_ sender: Any) {
        if(mode == 0) {
           mode = 1
        } else {
            mode = 0
        }
        tableView.reloadData()
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
            projects[projectIndex].task_cnt += 1
            tableView.insertRows(at: [IndexPath(row: data.count-1, section: 0)], with: .automatic)
        }
        else {
            // 編集開始のプロジェクトと現在のプロジェクトが異なる場合
            if (task.project_id != projectIndex) {
                // 元のプロジェクトからタスクを削除
                projects[task.project_id].tasks.remove(at: index)
                projects[task.project_id].task_cnt -= 1
                // 現在のプロジェクトの末尾に追加
                data.insert(task, at:projects[projectIndex].task_cnt-1)
                projects[projectIndex].tasks.insert(task, at:projects[projectIndex].task_cnt-1)
                tableView.insertRows(at: [IndexPath(row: data.count-1, section: 0)], with: .automatic)
                tableView.reloadData()
            }
            else {
                let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
                cell?.isHighlighted = false
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
    func didCancelRegistTask(index:Int) {
        if index > 0 {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.isHighlighted = false
        }
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
            /*
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
            */
            let task = Task()
            task.name = ""
            task.date = dtFormatter.string(from: Date())
            //task.start_time = "\(hour):" + String(format:"%02d",min)
            task.start_time = ""
            task.estimated_time = "1.0"
            task.duration = "00:00"
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
    /*
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = data[sourceIndexPath.row]
        data.remove(at: sourceIndexPath.row)
        data.insert(item, at: destinationIndexPath.row)
        // projects.tasks 内の順番の入れ替え
        projects[projectIndex].tasks = data
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0;
        if (mode == 0) {
            count = projects[0].task_cnt
        } else {
            count = data.count - projects[0].task_cnt
        }
        return count
    }
    // プロジェクトに紐づくタスク一覧表示制御
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "taskcell", for: indexPath) as? TaskCell {
            var row:Int = indexPath.row;
            if (mode == 1) {
                row = indexPath.row + projects[0].task_cnt
            }
            let task = data[row]
            cell.delegate = self
            // TODO 配列の長さに応じたループ回数でないとエラーになる(現状は10回固定)
            cell.date.text = task.date
            cell.taskName.text = task.name
            cell.star.tag = indexPath.row
            cell.doneButton.tag = indexPath.row
            cell.timerButton.tag = indexPath.row
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
            // タイマーボタンのスタイル変更
            cell.timerButton.layer.borderColor = UIColor.gray.cgColor
            cell.timerButton.layer.borderWidth = 0.8
            cell.timerButton.layer.cornerRadius = 6.0
            cell.timerButton.backgroundColor = peachColor
            
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
        swipeCellA.backgroundColor = swipeEditColor
        swipeCellB.backgroundColor = swipeDeleteColor
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
        var toIndex = projects[projectIndex].task_cnt-1
        if data[index].priority_flg == "1" {
            let item = data[index]
            data.remove(at: index)
            data.insert(item, at: 0)
            toIndex = 0
        } else {
            let item = data[index]
            data.remove(at: index)
            data.insert(item, at:toIndex)
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.tableView.beginUpdates()
            self.tableView.moveRow(at: IndexPath(row: index, section: 0), to: IndexPath(row: toIndex, section: 0))
            self.tableView.endUpdates()
        }, completion: {finish in
            for i in 0..<self.projects[self.projectIndex].task_cnt {
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
            }
        })
        projects[projectIndex].tasks = data
    }
    
    // タスク完了制御
    func execDone(_ index: Int) {
        let item = data[index]
        item.done_flg = "1"
        // 完了タスクを一覧から削除
        data.remove(at: index)
        data.insert(item, at: projects[0].task_cnt - 1)
        projects[0].tasks.remove(at: index)
        projects[0].tasks.insert(item, at: projects[0].task_cnt - 1)
        // 完了フラグを立てる
        projects[0].task_cnt = projects[0].task_cnt - 1
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
        // projects.tasks 内の順番の入れ替え
        projects[projectIndex].tasks = data
    }
}

// スライドメニューバー処理
extension ViewController: SidemenuViewControllerDelegate {
    func getNavigationBarHight() -> CGFloat {
        return naviBar.frame.size.height
    }
    
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
        data = projects[0].tasks
        tableView.reloadData()
    }
    
    func getProjects() -> [Project] {
        return projects
    }

    func appendProject(project: Project){
        projects.append(project)
    }

    func deleteProject(index:Int){
        projects.remove(at: index)
    }
    
    func moveProject(sourceIndex: Int, destinationIndex: Int){
        let proj = projects[sourceIndex]
        projects.remove(at: sourceIndex)
        projects.insert(proj, at: destinationIndex)
    }
}

