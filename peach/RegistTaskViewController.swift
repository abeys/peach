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
    func didCancelRegistTask(index:Int)
}

class RegistTaskViewController : UIViewController {
    
    var index:Int?
    var task:Task?
    
    var dateSelect:[String] = []
    var timeSelect:[String] = []
    let durationSelect:[String] = ["","0.5","1.0","1.5","2.0","2.5","3.0","3.5","4.0","4.5","5.0"]
    
    var delegate:RegistTaskViewControllerDelegate? = nil
    let height = 150
    let duration = 0.3
    
    @IBOutlet weak var taskName: UITextField!
    
    @IBOutlet weak var duedate: UILabel!
    @IBOutlet weak var starttime: UILabel!
    @IBOutlet weak var span: UILabel!
    
    @IBOutlet weak var btnChange: PickerViewKeyboard!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnRegist: UIButton!
    
    func labelDesign(_ label:UILabel) {
        label.textColor = UIColor.gray
        label.backgroundColor = UIColor.white
        label.layer.borderColor = UIColor.gray.cgColor
        label.layer.borderWidth = 0.5
        label.layer.cornerRadius = 5.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnChange.delegate = self
        btnCancel.backgroundColor = UIColor.orange
        
        labelDesign(duedate)
        labelDesign(starttime)
        labelDesign(span)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegistTaskViewController.changeNotifyTextField(sender:)), name: UITextField.textDidChangeNotification, object: nil)
        
        generateSelection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        taskName.text = task?.name
        duedate.text = task?.date
        starttime.text = task?.start_time
        span.text = task?.estimated_time
        redraw()
    }
    
    func redraw() {
        // ボタン表示の調整
        if (taskName.text?.count)! > 0 {
            btnRegist.isEnabled = true
            btnRegist.backgroundColor = UIColor.orange
        }
        else {
            btnRegist.isEnabled = false
            btnRegist.backgroundColor = UIColor.lightGray
        }
    }
    
    func generateSelection() {
        //選択肢を初期化する
        let formatter = DateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        formatter.dateFormat = "MM/dd"
        var components = DateComponents()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateSelect = [""]
        for i in -6 ... 7 {
            components.setValue(i,for: Calendar.Component.day)
            let wk = calendar.date(byAdding: components, to: Date())!
            dateSelect.append(formatter.string(from: wk))
        }
        
        timeSelect = [""]
        for i in 0 ... 23 {
            timeSelect.append("\(i):00")
            timeSelect.append("\(i):30")
        }
    }
    
    @IBAction func clickChange(_ sender: Any) {
        generateSelection()
    }
    
    @IBAction func clickRegist(_ sender: Any) {
        task?.name = taskName.text
        task?.date = duedate.text
        task?.start_time = starttime.text
        task?.estimated_time = span.text
        delegate?.didRegistTask(index: index!, task: task!)
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        if delegate != nil {
            delegate?.didCancelRegistTask(index: index!)
        }
    }
    
    @objc public func changeNotifyTextField (sender: NSNotification) {
        guard let textView = sender.object as? UITextField else {
            return
        }
        if textView.text != nil {
            redraw()
        }
    }
}

extension RegistTaskViewController: PickerViewKeyboardDelegate {
    func initData()->[Int] {
        return [dateSelect.firstIndex(of: duedate.text!) ?? 0,
                timeSelect.firstIndex(of: starttime.text!) ?? 0,
                durationSelect.firstIndex(of: span.text!) ?? 0]
    }
    func dateSelect(sender: PickerViewKeyboard) -> [String] {
        return dateSelect
    }
    func timeSelect(sender: PickerViewKeyboard) -> [String] {
        return timeSelect
    }
    func durationSelect(sender: PickerViewKeyboard) -> [String] {
        return durationSelect
    }
    func didDone(sender: PickerViewKeyboard, selectedData: [Int]) {
        duedate.text = dateSelect[selectedData[0]]
        starttime.text = timeSelect[selectedData[1]]
        span.text = durationSelect[selectedData[2]]
        self.btnChange.resignFirstResponder()
    }
    func didCancel(sender: PickerViewKeyboard) {
        self.btnChange.resignFirstResponder()
    }
}

protocol PickerViewKeyboardDelegate {
    func initData()->[Int]
    func dateSelect(sender: PickerViewKeyboard)->[String]
    func timeSelect(sender: PickerViewKeyboard)->[String]
    func durationSelect(sender: PickerViewKeyboard)->[String]
    func didCancel(sender: PickerViewKeyboard)
    func didDone(sender: PickerViewKeyboard, selectedData: [Int])
}

class PickerViewKeyboard: UIButton {
    var delegate: PickerViewKeyboardDelegate!
    var pickerView: UIPickerView!
    // なんだがpickerViewが正しいselectedを返却しないので、イベントでがんばるwww
    var selval:[Int]=[]
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var dateSelect:[String] {
        return delegate.dateSelect(sender: self)
    }
    
    var timeSelect:[String] {
        return delegate.timeSelect(sender: self)
    }
    
    var durationSelect:[String] {
        return delegate.durationSelect(sender: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc func didTouchUpInside(_ sender: UIButton) {
        becomeFirstResponder()
    }
    
    override var inputView: UIView? {
        pickerView = UIPickerView()
        pickerView.delegate = self
        // 初期値をセットする
        let initrow = delegate.initData()
        pickerView.selectRow(initrow[0], inComponent: 0, animated: false)
        pickerView.selectRow(initrow[1], inComponent: 1, animated: false)
        pickerView.selectRow(initrow[2], inComponent: 2, animated: false)
        selval = initrow
        return pickerView
    }
    
    override var inputAccessoryView: UIView? {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 44)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 12
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(PickerViewKeyboard.cancelPicker))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PickerViewKeyboard.donePicker))
        
        let toolbarItems = [space, cancelItem, flexSpaceItem, doneButtonItem, space]
        
        toolbar.setItems(toolbarItems, animated: true)
        
        return toolbar
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selval[component] = row
    }
    
    @objc func cancelPicker() {
        delegate.didCancel(sender: self)
    }
    
    @objc func donePicker() {
        delegate.didDone(sender: self, selectedData: [selval[0],selval[1],selval[2]])
    }
}

extension PickerViewKeyboard : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return dateSelect.count
        case 1:
            return timeSelect.count
        case 2:
            return durationSelect.count
        default:
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return dateSelect[row]
        case 1:
            return timeSelect[row]
        case 2:
            return durationSelect[row]
        default:
            return ""
        }
    }
}
