//
//  CardCollectionViewCell.swift
//  InstNews
//
//  Created by Igor on 1/17/19.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import CoreImage

protocol Bluring {
    func addBlur(_ alpha: CGFloat)
}

class CardCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageArticle: UIImageView!
    @IBOutlet weak var titleArticle: UILabel!
    @IBOutlet weak var moreInformationOutlet: UIButton!
    @IBOutlet weak var darkView: UIView!
    
    weak var delegate: ScrollNextCell?
    weak var goToNextVCDelegate: CellDelegator?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awakeFromNib")
        moreInformationOutlet.layer.cornerRadius = 0.5 * moreInformationOutlet.bounds.size.width
        moreInformationOutlet.imageView?.layer.cornerRadius = 0.5 * moreInformationOutlet.bounds.size.width
        moreInformationOutlet.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
    }

    @IBAction func tapMoreInformationButton(_ sender: Any) {
        goToNextVCDelegate?.goToAnotherScreen(indexNews: delegate!.currentNewsCell)
        
    }

    func logDefinition(newsResource: String) -> UIImage? {
        switch newsResource {
        case "bbc-news":
            return UIImage(named: "bbc-news.png")
        case "business-insider":
            return UIImage(named: "business-insider.png")
        case "bloomberg":
            return UIImage(named: "bloomberg.png")
        case "cnn":
            return UIImage(named: "cnn.png")
        case "buzzfeed" :
            return UIImage(named: "buzzfeed.png")
        case "daily-mail":
            return UIImage(named: "daily-mail.png")
        case "fortune":
            return UIImage(named: "fortune.png")
        case "fox-news":
            return UIImage(named: "fox-news.png")
        case "google-news":
            return UIImage(named: "google-news.png")
        case "independent":
            return UIImage(named: "independent.png")
        case "mashable":
            return UIImage(named: "mashable.png")
        case  "mirror":
            return UIImage(named: "mirror.png")
        case  "national-geographic":
            return UIImage(named: "national-geographic.png")
        case "nbc-news":
            return UIImage(named: "nbc-news.png")
        case "techcrunch":
            return UIImage(named: "techcrunch.png")
        case  "the-guardian-au":
            return UIImage(named: "the-guardian-au.png")
        case "the-new-york-times":
            return UIImage(named: "the-new-york-times.png")
        case "the-telegraph":
            return UIImage(named: "the-telegraph.png")
        case "the-verge":
            return UIImage(named: "the-verge.png")
        case "the-wall-street-journal":
            return UIImage(named: "the-wall-street-journal.png")
        case "time":
            return UIImage(named: "time.png")
        default:
            return nil
        }
    }
}
