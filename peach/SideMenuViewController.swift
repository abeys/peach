//
//  SideMenuViewController.swift
//  peach
//
//  Created by 菊池健司 on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit

protocol SidemenuViewControllerDelegate: class {
    func parentViewControllerForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> UIViewController
    func shouldPresentForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> Bool
    func sidemenuViewControllerDidRequestShowing(_ sidemenuViewController: SideMenuViewController, contentAvailability: Bool, animated: Bool)
    func sidemenuViewControllerDidRequestHiding(_ sidemenuViewController: SideMenuViewController, animated: Bool)
    func sidemenuViewController(_ sidemenuViewController: SideMenuViewController, didSelectItemAt indexPath: IndexPath)
    func getProjects() -> [Project]
    func setProjectName(projectName: String)
    func appendProject(project: Project)
}

class SideMenuViewController: UIViewController {
    private let contentView = UIView(frame: .zero)
    private let tableView = UITableView(frame: .zero, style: .plain)
    weak var delegate: SidemenuViewControllerDelegate?
    var sections:[String] = ["プロジェクト"]
    var tags:[String] = ["task","meeting","休憩"]
    var projects:[Project] = []
    
    private var contentMaxWidth: CGFloat {
        return view.bounds.width * 0.8
    }
    
    private var contentRatio: CGFloat {
        get {
            return contentView.frame.maxX / contentMaxWidth
        }
        set {
            let ratio = min(max(newValue, 0), 1)
            contentView.frame.origin.x = contentMaxWidth * ratio - contentView.frame.width
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowRadius = 3.0
            contentView.layer.shadowOpacity = 0.8
            
            view.backgroundColor = UIColor(white: 0, alpha: 0.3 * ratio)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var contentRect = view.bounds
        contentRect.size.width = contentMaxWidth
        contentRect.origin.x = -contentRect.width
        contentView.frame = contentRect
        contentView.backgroundColor = .white
        contentView.autoresizingMask = .flexibleHeight
        view.addSubview(contentView)
        
        projects = (delegate?.getProjects())!
        
        tableView.frame = contentView.bounds
        tableView.separatorInset = .zero
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")
        contentView.addSubview(tableView)
        tableView.reloadData()
        
        let button =  UIButton(frame: CGRect(x: self.view.frame.width-150, y: self.view.frame.height-100, width: self.view.frame.width, height: self.view.frame.height / 4))
        button.setTitle(" + ", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.backgroundColor = UIColor.red
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 14.0
        button.sizeToFit()
        button.addTarget(self, action: #selector(addProject(_:)), for: UIControl.Event.touchUpInside)
        contentView.addSubview(button)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(sender:)))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func backgroundTapped(sender: UITapGestureRecognizer) {
        hideContentView(animated: true) { (_) in
            self.willMove(toParent: nil)
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
    
    func showContentView(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.contentRatio = 1.0
            }
        } else {
            contentRatio = 1.0
        }
    }
    
    func hideContentView(animated: Bool, completion: ((Bool) -> Swift.Void)?) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentRatio = 0
            }, completion: { (finished) in
                completion?(finished)
            })
        } else {
            contentRatio = 0
            completion?(true)
        }
    }
    @objc func addProject(_ sender: UIButton) {
        let controller = UIAlertController(title: "新規プロジェクトの追加",
                                           message: "プロジェクト名を入力してください。",
                                           preferredStyle: .alert)
        controller.addTextField { textField in
            textField.placeholder = "パスワード"
            textField.isSecureTextEntry = false
            textField.keyboardAppearance = .dark
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "追加する",
                                      style: .default) { action in
                                        if let projectName = controller.textFields?.first?.text {
                                            let project = Project()
                                            let newTask = Task()
                                            project.tasks.append(newTask)
                                            project.project_name = projectName
                                            self.projects.append(project)
                                            self.delegate?.appendProject(project:project)
                                            self.tableView.reloadData()
                                        }
        }
        controller.addAction(cancelAction)
        controller.addAction(addAction)
        self.present(controller, animated: true, completion: nil)
    }
}

extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return projects.count
        }
        else {
            return tags.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Default", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = projects[indexPath.row].project_name
        }
        else {
            cell.textLabel?.text = tags[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.sidemenuViewController(self, didSelectItemAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " ◆ " + sections[section]
    }
}

extension SideMenuViewController: UIGestureRecognizerDelegate {
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: tableView)
        if tableView.indexPathForRow(at: location) != nil {
            return false
        }
        return true
    }
}
