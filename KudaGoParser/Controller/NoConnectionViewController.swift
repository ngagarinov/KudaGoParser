//
//  NoConnectionViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 30.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class NoConnectionViewController: UIViewController {

    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBar()
        
    }
    
    func setNavBar() {
    
    let red = UIColor(red: 0.9, green: 0.24, blue: 0.22, alpha: 0.96)
    navigationController?.setNavigationBarHidden(true, animated: false)
    navBarView.backgroundColor = red
    titleLabel.text = "Невозможно загрузить данные, проверьте соединение с интернетом."
    if let statusbar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
        statusbar.backgroundColor = red
    }
    UIApplication.shared.statusBarStyle = .lightContent
    view.backgroundColor = red
    }
}
