//
//  NoConnectionViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 30.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class NoConnectionViewController: UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let redColor = UIColor(red: 0.9, green: 0.24, blue: 0.22, alpha: 0.96)
    
    //MARK: NoConnectionViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setNavBar() {
        navBarView.backgroundColor = redColor
        titleLabel.text = "Невозможно загрузить данные, проверьте соединение с интернетом."
        view.backgroundColor = redColor
        if #available(iOS 13.0, *) {
            let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
            statusBarView.backgroundColor = redColor
            view.addSubview(statusBarView)
        } else {
            if let statusbar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusbar.backgroundColor = redColor
            }
        }
    }
}
