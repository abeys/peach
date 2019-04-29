//
//  RegistTaskViewController.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit

protocol RegistTaskViewControllerDelegate: class {

    func didRegistTask(index:Int, task:Task)
    func didCancelRegistTask()
}

class RegistTaskViewController : UIViewController,UITextFieldDelegate {
    
    var index:Int? = -1
    
    var delegate:RegistTaskViewControllerDelegate? = nil
    let height = 150
    let duration = 0.2
    var task:Task? = Task()
    
    @IBOutlet weak var taskName: UITextField!
    
    @IBOutlet weak var btnRegist: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskName.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        redraw()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        redraw()
    }
    
    func redraw() {
        
        if (taskName.text?.count)! > 0 {
            btnRegist.isEnabled = true
        }
        else {
            //btnRegist.isEnabled = false
        }
    }
    
    @IBAction func clickChange(_ sender: Any) {
        
    }
    
    @IBAction func clickRegist(_ sender: Any) {
        task?.task_id = 1
        task?.project_id = 1
        task?.name = taskName.text
        task?.date = "4/29"
        task?.start_time = "13:00"
        task?.done_flg = "0"
        task?.duration = "1.5h"
        task?.rabel = ""
        delegate?.didRegistTask(index: index!, task: task!)
        
    }
}
