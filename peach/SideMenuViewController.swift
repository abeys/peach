//
//  SideMenuViewController.swift
//  peach
//
//  Created by 菊池健司 on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit
import SwiftReorder

protocol SidemenuViewControllerDelegate: class {
    func parentViewControllerForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> UIViewController
    func shouldPresentForSidemenuViewController(_ sidemenuViewController: SideMenuViewController) -> Bool
    func sidemenuViewControllerDidRequestShowing(_ sidemenuViewController: SideMenuViewController, contentAvailability: Bool, animated: Bool)
    func sidemenuViewControllerDidRequestHiding(_ sidemenuViewController: SideMenuViewController, animated: Bool)
    func sidemenuViewController(_ sidemenuViewController: SideMenuViewController, didSelectItemAt indexPath: IndexPath)
    func getProjects() -> [Project]
    func appendProject(project: Project)
    func deleteProject(index: Int)
    func moveProject(sourceIndex: Int, destinationIndex: Int)
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
        tableView.reorder.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Default")
        contentView.addSubview(tableView)
        tableView.reloadData()
        
//        let button =  UIButton(frame: CGRect(x: self.view.frame.width-150, y: self.view.frame.height-100, width: self.view.frame.width, height: self.view.frame.height / 4))
        let button =  UIButton(frame: CGRect(x: self.view.frame.width-200, y: self.view.frame.height-150, width: 70, height: 70))
        button.setTitle("+", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 48)
        button.backgroundColor = UIColor(red: 0/255, green: 184/255, blue: 0/255, alpha: 1)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 35
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 5,right: 0)
//        button.sizeToFit()
        button.addTarget(self, action: #selector(addProject(_:)), for: UIControl.Event.touchUpInside)
        contentView.addSubview(button)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(sender:)))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func backgroundTapped(sender: UITapGestureRecognizer) {
        delegate?.sidemenuViewController(self, didSelectItemAt: IndexPath(row: 0, section: 0))
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
            textField.placeholder = "プロジェクト名"
            textField.isSecureTextEntry = false
            textField.keyboardAppearance = .dark
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "追加する",
                                      style: .default) { action in
                                        if let projectName = controller.textFields?.first?.text {
                                            let project = Project()
                                            //let newTask = Task()
                                            project.tasks = []
                                            project.project_name = projectName
                                            project.project_id = self.projects.count
                                            self.projects.append(project)
                                            self.delegate?.appendProject(project:project)
                                            self.tableView.reloadData()
                                        }
        }
        controller.addAction(cancelAction)
        controller.addAction(addAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    func editProject(index:Int) {
        let controller = UIAlertController(title: "プロジェクト名の編集",
                                           message: "プロジェクト名を入力してください。",
                                           preferredStyle: .alert)
        controller.addTextField { textField in
            textField.text = self.projects[index].project_name
            textField.isSecureTextEntry = false
            textField.keyboardAppearance = .dark
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        let addAction = UIAlertAction(title: "更新する",
                                      style: .default) { action in
                                        if let projectName = controller.textFields?.first?.text {
                                            self.projects[index].project_name = projectName
                                            self.tableView.reloadData()
                                        }
        }
        controller.addAction(cancelAction)
        controller.addAction(addAction)
        self.present(controller, animated: true, completion: nil)
    }

    func deleteProject(index:Int) {
        self.projects.remove(at: index)
        delegate?.deleteProject(index: index)
        self.tableView.reloadData()
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
        // ドラッグされているセルを返す
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
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
        let proj = projects[indexPath.row]
        projects.remove(at: indexPath.row)
        projects.insert(proj, at: 0)
        self.tableView.reloadData()
        delegate?.moveProject(sourceIndex: indexPath.row, destinationIndex: 0)
        delegate?.sidemenuViewController(self, didSelectItemAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " ◆ " + sections[section]
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "編集",
                                            handler: { (action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
                                                self.editProject(index: indexPath.row)
                                                // 処理を実行できなかった場合はfalse
                                                completion(false)
        })
        editAction.backgroundColor = UIColor(red: 101/255.0, green: 198/255.0, blue: 187/255.0, alpha: 1)
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "削除",
                                              handler: {(action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
                                                self.deleteProject(index: indexPath.row)
                                                // 処理を実行完了した場合はtrue
                                                completion(true)
        })
        deleteAction.backgroundColor = UIColor(red: 214/255.0, green: 69/255.0, blue: 65/255.0, alpha: 1)

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
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

extension SideMenuViewController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update data model
        let proj = projects[sourceIndexPath.row]
        projects.remove(at: sourceIndexPath.row)
        projects.insert(proj, at: destinationIndexPath.row)
        delegate?.moveProject(sourceIndex: sourceIndexPath.row, destinationIndex: destinationIndexPath.row)
    }
}
