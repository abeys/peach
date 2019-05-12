//
//  TaskCell.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: class {
    func changePriority(_ index:Int, _ priority:String)
}

class TaskCell : UITableViewCell {
    var task : Task?
    var delegate : TaskCellDelegate?
    // タスクIDラベル
    @IBOutlet weak var taskId: UILabel!
    // タスク名ラベル
    @IBOutlet weak var taskName: UILabel!
    // 開始予定時間ラベル
    @IBOutlet weak var date: UILabel!
    //開始予定時間ラベル
    @IBOutlet weak var time: UILabel!
    // 作業時間
    @IBOutlet weak var workedTime: UILabel!
    // 優先アイコン
    @IBOutlet weak var star: UIButton!
    // 優先アイコンアクション
    @IBAction func priorityStar(_ sender: Any) {
        let button = sender as! UIButton
        if task?.priority_flg == "0" {
            delegate?.changePriority(button.tag, "1")
        } else {
            delegate?.changePriority(button.tag, "0")
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            self.contentView.backgroundColor = UIColor.lightGray
        }
        else {
            self.contentView.backgroundColor = UIColor.white
        }
    }
}
