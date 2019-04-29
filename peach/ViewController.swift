//
//  ViewController.swift
//  peach
//
//  Created by matsumura shiori on 2019/04/29.
//  Copyright © 2019 matsumura shiori. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    let sidemenuViewController = SideMenuViewController()
    let contentViewController = UINavigationController(rootViewController: UIViewController())
    
    private var isShownSidemenu: Bool {
        return sidemenuViewController.parent == self
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        contentViewController.viewControllers[0].view.backgroundColor = .white
        contentViewController.viewControllers[0].navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sidemenu", style: .plain, target: self, action: #selector(sidemenuBarButtonTapped(sender:)))
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)
        
        sidemenuViewController.delegate = self
    }

    @objc private func sidemenuBarButtonTapped(sender: Any) {
        showSidemenu(animated: true)
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
}

