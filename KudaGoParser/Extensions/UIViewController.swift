//
//  UIViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 24.11.2019.
//  Copyright © 2019 nikita. All rights reserved.
//

import UIKit

extension UIViewController {
   
   class func loadFromStoryboard<T: UIViewController>() -> T {
       let name = String(describing: T.self)
       let storyboard = UIStoryboard(name: name, bundle: nil)
       if let viewController = storyboard.instantiateInitialViewController() as? T {
           return viewController
       } else {
           fatalError("Error: No initial view controller in \(name) storyboard!")
       }
   }
}
