//
//  ViewController.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var data = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
    var projects:[Project] = []

    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    let sidemenuViewController = SideMenuViewController()
    let contentViewController = UINavigationController(rootViewController: UIViewController())
    
    var isShowRegistTask: Bool = false
    
    private var isShownSidemenu: Bool {
        return sidemenuViewController.parent == self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // テスト用データ
        var tasks:[Task] = []
        let task1 = Task()
        task1.project_id="001"
        task1.project="プロジェ１"
        task1.name="001-タスク１"
        task1.date="2019-04-01"
        task1.start_time="00:00"
        task1.done_flg="0"
        task1.duration="01:00"
        task1.rabel="作業"
        tasks.append(task1)
        let project1 = Project()
        project1.project_id = "001"
        project1.tasks = tasks
        projects.append(project1)

        // デフォルトで先頭のプロジェクト名を表示
        naviItem.title = projects[0].project_id

        sidemenuViewController.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func tapAddTask(_ sender: Any) {
        showRegistTask(animated: true)
    }
    
    @IBAction func tapSidemenu(_ sender: Any) {
        showSidemenu(animated: true)
    }
    
    private func showRegistTask(contentAvailability: Bool = true, animated: Bool) {
        if isShowRegistTask {
            return
        }
        // ナビゲーションバーの高さを取得する
        let navHeight = naviBar.frame.size.height + 10
        // StoryBoardのインスタンスから、RegistTaskViewControllerを取得する
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registVC = storyboard.instantiateViewController(withIdentifier: "registTask") as! RegistTaskViewController
        let registView = registVC.view
        // 表示するRegistTaskの大きさ、位置を計算する
        var contentRect = registView!.bounds
        contentRect.size.height = CGFloat(registVC.height)
        contentRect.origin.y = navHeight - contentRect.height
        registView!.frame = contentRect
        registView!.autoresizingMask = .flexibleWidth
        view.addSubview(registView!)
        view.sendSubviewToBack(registView!)
        view.sendSubviewToBack(tableView)
        
        // アニメーションで動かす
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            registView!.center.y += CGFloat(registVC.height)
        }, completion: nil)
        /*
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.tableView!.center.y += CGFloat(registVC.height)
        }, completion: nil)
        */
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "taskcell", for: indexPath) as? TaskCell {
            cell.taskId.text = String(data[indexPath.row])
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
    
    func swipeContentsTap(content: String, index: Int) {
        print("タップされたのは" + index.description + "番のセルで" + "内容は" + content + "でした")
    }
    
}

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
        hideSidemenu(animated: true)
    }

    func getProjects() -> [Project] {
        return projects
    }
    
    func setProjectName(projectName: String){
        naviItem.title = projectName
    }
}

