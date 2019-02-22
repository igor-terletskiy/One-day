//
//  DetailedDescriptionViewController.swift
//  InstNews
//
//  Created by Igor on 1/18/19.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class DetailedDescriptionViewController: UIViewController {
  
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var briefArticleDescription: UITextView!
    @IBOutlet weak var openButtomWebView: UIButton!
    
    var url: String?
    var article: String?
    var imageUrl: String?
    var articleDescription: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openButtomWebView.layer.cornerRadius = 0.5 * openButtomWebView.bounds.size.width
        self.openButtomWebView.layer.shadowColor = UIColor.darkGray.cgColor;
        self.openButtomWebView.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.openButtomWebView.layer.shadowOpacity = 1.0;
        self.openButtomWebView.layer.shadowRadius = 0.0;
        
        articleTitle.text = article
        briefArticleDescription.text = articleDescription
        print(imageUrl)
        if let imageURL = imageUrl {
            if let url = URL(string: imageURL) {
                newsImage.load(url: url) { (image) in
                    self.newsImage.image = image
                }
            }
        } else {
            newsImage.image = UIImage(named: "imageNotFound")
        }
    }
    
    @IBAction func returnToMainScreen() {
         dismiss(animated: true, completion: nil)
    }

    @IBAction func openLinkToNews() {
        UIApplication.shared.openURL(NSURL(string: url!)! as URL)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
