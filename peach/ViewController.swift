//
//  ViewController.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    var sections:[String] = ["プロジェクト"] //["プロジェクト","タグ"]
    var projects:[String] = ["WORK","仕事","アプリ開発","PaDia","プライベート"]
    var tags:[String] = ["task","meeting","休憩"]
    
    var data = [1,2,3,4,5,6,7]
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
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

