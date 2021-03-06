//
//  randomNewsViewController.swift
//  PUMBA
//
//  Created by apple on 07/04/18.
//  Copyright © 2018 Sonkar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage

class randomNewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var newsTable: UITableView!
    var dictArray : [Dictionary<String , AnyObject>] = []
    var selectedNews : [String: AnyObject] = ["nalla":"nallu" as AnyObject]
    var cacheImage = NSCache<AnyObject, AnyObject>()
    var urlString : String?
    var image : UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsTable.delegate = self
        newsTable.dataSource = self
        
        checkAndFetch()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if dictArray.count > 20{
            return 20
        }
        return dictArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "randomNewsCell", for: indexPath) as! randomTableViewCell
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
            urlString = url
            //fetchImage(url: url)
            cell.newsImage.sd_setImage(with: getUrl, completed: nil)
        }
        cell.newsImage.image = image
        return cell
        
    }
    
    func checkAndFetch() {
        
        //tocheck for any edits in data base and modify table accordingly
        
        Database.database().reference().child("random-content").observe(.value) { (snapshot) in
            
            if let dataDictionary = snapshot.value as? [String: AnyObject]{
                
                self.dictArray = []
                for news in dataDictionary.values {
                    
                    self.dictArray.append(news as! Dictionary<String, AnyObject>)
                }
                self.newsTable.reloadData()
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedNews = dictArray[indexPath.row]
        performSegue(withIdentifier: "randomNewsSegue", sender: nil)
        print(selectedNews)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("into perform segue")
        
        if let viewNewsVC = segue.destination as? displayNewsViewController{
            
            viewNewsVC.news = selectedNews
        }
        
    }
    
    func fetchImage(url: String) -> Void {
        if let imagefromCache = cacheImage.object(forKey: url as AnyObject) as? UIImage{
            self.image = imagefromCache
            return
        }
    
        let getUrl = URL(string: url)
        URLSession.shared.dataTask(with: getUrl!) { (data, response, error) in
            
            if error != nil{
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data!)
                
                if self.urlString == url {
                    self.image = imageToCache
                }
                self.cacheImage.setObject(imageToCache!, forKey: self.urlString as AnyObject)
                
            }
            self.newsTable.reloadData()
        }.resume()
    }
    
}
