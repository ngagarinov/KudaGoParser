//
//  DetailViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 24.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var eventId: Int?
    var eventPlace: String?
    var eventPrice: String?
    var eventDate: String?
    var eventDesc: String?
    var eventTitle: String?
    var eventDetail: String?
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    var parseManager = ParseManager()
    private var roundButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView?.estimatedRowHeight = 231
        tableView?.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.isNavigationBarHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        parseManager.parseKudaGo(request: parseType.detail(id: eventId!).request, parse: .images) {_ in
            self.tableView?.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createFloatingButton()
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.roundButton.superview != nil {
            DispatchQueue.main.async {
                self.roundButton.removeFromSuperview()
                //roundButton = nil
            }
        }
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.isNavigationBarHidden = false
    }
   


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DetailViewCell
        
        let countOfImages = parseManager.listOfDetailImages.count
        cell.pageControl.numberOfPages = countOfImages
        
        for index in 0..<countOfImages {
            
            frame.origin.x = cell.scrollView.frame.size.width * CGFloat(index)
            frame.size = cell.scrollView.frame.size
            
            let imgView = UIImageView(frame: frame)
            
            let url = URL(string:  parseManager.listOfDetailImages[index].image)
            imgView.sd_setImage(with: url )
            // imgView.image = UIImage(
            cell.scrollView.addSubview(imgView)
        }
        
        cell.scrollView.contentSize = CGSize(width: (cell.scrollView.frame.size.width * CGFloat(countOfImages)), height: cell.scrollView.frame.size.height)
        
        cell.titleLabel.text = eventTitle?.uppercased()
        cell.descriptionLabel.text = eventDesc?.html2String
        cell.detailLabel.text = eventDetail?.html2String
        

        
        return cell

    }
    
    func createFloatingButton() {
        roundButton = UIButton(type: .custom)
        roundButton.translatesAutoresizingMaskIntoConstraints = false
        roundButton.backgroundColor = .white
        // Make sure you replace the name of the image:
        roundButton.setImage(UIImage(named:"back"), for: .normal)
        // Make sure to create a function and replace DOTHISONTAP with your own function:
        roundButton.addTarget(self, action: #selector(backAction), for: UIControlEvents.touchUpInside)
        // We're manipulating the UI, must be on the main thread:
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(self.roundButton)
                NSLayoutConstraint.activate([
                    keyWindow.leadingAnchor.constraint(equalTo: self.roundButton.leadingAnchor, constant: -8),
                    keyWindow.topAnchor.constraint(equalTo: self.roundButton.topAnchor, constant: -27),
                    self.roundButton.widthAnchor.constraint(equalToConstant: 48),
                    self.roundButton.heightAnchor.constraint(equalToConstant: 32)])
            }
            // Make the button round:
            self.roundButton.layer.cornerRadius = 16
            // Add a black shadow:
            self.roundButton.layer.shadowColor = UIColor.lightGray.cgColor
            self.roundButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            self.roundButton.layer.masksToBounds = false
            self.roundButton.layer.shadowRadius = 4.0
            self.roundButton.layer.shadowOpacity = 0.5
            
        }
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
