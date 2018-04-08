//
//  SportsNewsViewController.swift
//  PUMBA
//
//  Created by apple on 07/04/18.
//  Copyright © 2018 Sonkar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage

class SportsNewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var sportsNewsTable: UITableView!
    
    var dictArray : [Dictionary<String , AnyObject>] = []
    var selectedNews : [String: AnyObject] = ["nalla":"nallu" as AnyObject]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sportsNewsTable.delegate = self
        sportsNewsTable.dataSource = self
        
        checkAndFetch()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sportsCell", for: indexPath) as! randomTableViewCell
        //setting values in cell
        let news = dictArray[indexPath.row]
        if let title =  news["mNewsHeading"] as? String{
            cell.titleLabel?.text = title
        }
        else{
            cell.titleLabel?.text = "Error Loading!"
        }
        
        if let url = (news["mNewsImageUrl1"] as? String){
            let getUrl = URL(string: url)
            cell.newsImage.sd_setImage(with: getUrl, completed: nil)
        }
        
        return cell
        
    }
    
    func checkAndFetch() {
        
        //tocheck for any edits in data base and modify table accordingly
        
        Database.database().reference().child("sports-section").observe(.value) { (snapshot) in
            
            if let dataDictionary = snapshot.value as? [String: AnyObject]{

                self.dictArray = []
                for news in dataDictionary.values {
                    
                    self.dictArray.append(news as! Dictionary<String, AnyObject>)
                }
                self.sportsNewsTable.reloadData()
            }
            
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedNews = dictArray[indexPath.row]
        performSegue(withIdentifier: "sportsNewsSegue", sender: nil)
        //print(selectedNews)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("into perform segue")
        
        if let viewNewsVC = segue.destination as? displayNewsViewController{
            
                      viewNewsVC.news = selectedNews
        }
        
    }

}
