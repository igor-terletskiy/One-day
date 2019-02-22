//
//  DatabaseManager.swift
//  InstNews
//
//  Created by Igor on 2/4/19.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class DatabaseManager {
    
    func createData(newsArray: Article?, images: UIImage?, countPage: String, currentDate: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newsEntity = NSEntityDescription.entity(forEntityName: "News", in: managedContext)!
        let news = NSManagedObject(entity: newsEntity, insertInto: managedContext)

        let fatchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        let result = try? managedContext.fetch(fatchRequest)
       
        print("Count element to DB: \(result?.count)")

        //Убираем дублирование данных
        
//        for data in result as! [NSManagedObject] {
//            if newsArray?.author  ==  data.value(forKey: "author") as? String &&
//            (newsArray?.author != nil && data.value(forKey: "author") as? String != nil) &&
//
//                newsArray?.content == data.value(forKey: "content") as? String &&
//            (newsArray?.content != nil && data.value(forKey: "content") as? String != nil) &&
//
//            newsArray?.description == data.value(forKey: "descriptionNews") as? String &&
//                (newsArray?.description != nil && data.value(forKey: "descriptionNews") as? String != nil) &&
//
//                newsArray?.source?.id ==  data.value(forKey: "id") as? String &&
//                (newsArray?.source?.id != nil && data.value(forKey: "id") as? String != nil) &&
//
//                newsArray?.source?.name ==  data.value(forKey: "name") as? String &&
//                (newsArray?.source?.name != nil && data.value(forKey: "name") as? String != nil) &&
//
//              newsArray?.publishedAt == data.value(forKey: "publishedAt") as? String &&
//                (newsArray?.publishedAt != nil && data.value(forKey: "publishedAt") as? String != nil ) &&
//
//                newsArray?.url == data.value(forKey: "url") as? String &&
//                (newsArray?.url != nil && data.value(forKey: "url") as? String != nil) &&
//
//              newsArray?.urlToImage == data.value(forKey: "urlToImage") as? String &&
//              (newsArray?.urlToImage != nil && data.value(forKey: "urlToImage") as? String != nil ) &&
//
//              newsArray?.title == data.value(forKey: "title") as? String &&
//              (newsArray?.title != nil && data.value(forKey: "title") as? String != nil) {
//
//                //добавить даты и номе страницы
//                print("delete news")
//              print(newsArray?.author)
//                print(data.value(forKey: "author") as? String)
//                print(newsArray?.content)
//                print(data.value(forKey: "content") as? String)
//                print(newsArray?.description)
//                print(data.value(forKey: "descriptionNews"))
//                print(newsArray?.source?.id)
//                print(data.value(forKey: "id") as? String)
//                print(newsArray?.source?.name)
//                print(data.value(forKey: "name") as? String)
//                print(newsArray?.publishedAt)
//                print(data.value(forKey: "publishedAt") as? String)
//                print(newsArray?.url)
//                print(data.value(forKey: "url") as? String)
//                print(newsArray?.urlToImage)
//                print(data.value(forKey: "urlToImage") as? String )
//                print(newsArray?.title)
//                print(data.value(forKey: "title") as? String)
//
//              managedContext.delete(data)
//                return;
//            }
//        }
        
        if let img = images {
            let data = img.pngData() as NSData?
            news.setValue(data, forKey: "dataImageNews")
        }
        
        news.setValue(newsArray?.author, forKey: "author")
        news.setValue(newsArray?.content, forKey: "content")
        news.setValue(newsArray?.description, forKey: "descriptionNews")
        news.setValue(newsArray?.source?.id, forKey: "id")
        news.setValue(newsArray?.source?.name, forKey: "name")
        news.setValue(newsArray?.publishedAt, forKey: "publishedAt")
        news.setValue(newsArray?.url, forKey: "url")
        news.setValue(newsArray?.urlToImage, forKey: "urlToImage")
        news.setValue(newsArray?.title, forKey: "title")
        news.setValue(countPage, forKey: "countPage")
        news.setValue(currentDate, forKey: "currentDate")
       
        do {
            try managedContext.save()
        } catch {
            print("Could not save. \(error), \(error.localizedDescription)")
        }
    }
    
    func retriveData() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fatchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        
        do {
            let result = try? managedContext.fetch(fatchRequest)
            print("Count element to DB: \(result?.count)")
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "author"))
                print(data.value(forKey: "content"))
                print(data.value(forKey: "descriptionNews"))
                print(data.value(forKey: "id"))
                print(data.value(forKey: "name"))
                print(data.value(forKey: "publishedAt"))
                print(data.value(forKey: "url"))
                print(data.value(forKey: "urlToImage"))
                print(data.value(forKey: "title"))
                print(data.value(forKey: "countPage"))
                print(data.value(forKey: "currentDate"))
                
                if let image =  data.value(forKey: "dataImageNews") {
                    print("image ok")
                } else {
                    print("image not found is nil")
                }
                //print(data.value(forKey: "dataImageNews"))
                print("**********************************")
                
            }
        } catch {
            print("Failed")
        }
    }
}
    func deleteAllData(_ entity:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        let managedContext = appDelegate.persistentContainer.viewContext

        do {
            let results = try managedContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                managedContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    
//    func updateData(newNewsArray: [Article]) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        let managerContext = appDelegate.persistentContainer.viewContext
//        let fetchRequst: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "News")
//        do {
//            let test = try managerContext.fetch(fetchRequst)
//            let objectToDelete = test[0] as! NSManagedObject
//            managerContext.delete(objectToDelete)
//
//            do {
//                try managerContext.save()
//            } catch {
//                print(error)
//            }
//        } catch {
//           print(error)
//        }
//    }
}
