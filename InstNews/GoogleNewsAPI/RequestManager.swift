//
//  RequestManager.swift
//  InstNews
//
//  Created by Igor on 1/16/19.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import UIKit

class GoogleNewResponse {
    
    static var countPage = 1 {
        didSet {
            print(oldValue)
        }
    }
    
    func  getCurentTime() -> (beginningOfTheDay: String, currentTimeAndDate: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let currentTimeAndDate = formatter.string(from: date)
        formatter.dateFormat = "yyyy-MM-dd"
        let beginningOfTheDay = formatter.string(from: date)
        
        return (beginningOfTheDay, currentTimeAndDate)
    }
    
    func gettingNews(fromTime: String, toTime: String, page: String, using completionHandler: @escaping (TopHeadlines) -> ()) {
        
        let session = URLSession.shared
        
        guard let url = URL(string: "https://newsapi.org/v2/everything?sources=bbc-news,business-insider,bloomberg,cnn,buzzfeed,daily-mail,fortune,fox-news,google-news,independent,mashable,mirror,national-geographic,nbc-news,techcrunch,the-guardian-au,the-new-york-times,the-telegraph,the-verge,the-wall-street-journal,time&pageSize=100&page=\(page)&from=\(fromTime)&to=\(toTime)&apiKey=f946d277aef149f5afd96be84d23dbb6") else { return }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            print(response)
            if let error = error {
                print(error.localizedDescription)
            }
            guard let data = data else {
                print("DATA ERROR!!!!")
                return
            }
            do {
                let response = try JSONDecoder().decode(TopHeadlines.self, from: data)
                completionHandler(response)
                print("count news array: ", response.articles?.count)

            } catch {
                print("RESPONSE EROOR")
                print(error)
            }
        }
        task.resume()
    }
}
