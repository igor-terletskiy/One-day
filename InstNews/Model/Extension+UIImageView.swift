//
//  Extension+UIImageView.swift
//  InstNews
//
//  Created by Igor on 1/17/19.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func load(url: URL, using completionHandler: @escaping (UIImage) -> ()) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                      completionHandler(image)
                    }
                }
            }
        }
    }
}
