//
//  ViewController.swift
//  InstNews
//
//  Created by Igor on 1/16/19.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import CoreData

protocol ScrollNextCell: class {
    var  currentNewsCell: Int { get set }
    func scrollToNextCell()
    func scrollToPreviousCell()
}

protocol CellDelegator: class {
    func goToAnotherScreen(indexNews: Int)
}

protocol TimerOptions: class {
    func resetTimer()
    func stopTimer()
    func startTimer()
}

class MainViewController: UIViewController, ScrollNextCell, CellDelegator {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var newsCollectionView: UICollectionView!
    
    private let requestManager = GoogleNewResponse()
    
    var currentNewsCell = 0
    let blure = BlureEffect()
    
    var progressTimer = Timer()
    var progress: Float = 0.0
    
    private let timeInterval = 0.01
    private var progressSteps: Float = 0.002
    
    weak var delegetSettingTimer: TimerOptions?
    let dataManager = DatabaseManager()
    
    var dataStoreg: [NSManagedObject]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fatchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
        let result = try? managedContext.fetch(fatchRequest)
        
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(statusManager),
                         name: .flagsChanged,
                         object: Network.reachability)
        
        updateUserInterface()
        
        if result == nil || (result?.isEmpty)! {
            DispatchQueue.global(qos: .userInteractive).async {
                self.requestManager.gettingNews(fromTime: self.requestManager.getCurentTime().beginningOfTheDay,
                                                toTime: self.requestManager.getCurentTime().currentTimeAndDate,
                                                page: "\(GoogleNewResponse.countPage)", using: { (request) in
                                                    
                                                    DispatchQueue.main.async {
                                                        if let article = request.articles {
                                                            for data in article {
                                                                self.dataManager.createData(newsArray: data, images: nil, countPage: "\(GoogleNewResponse.countPage)", currentDate: self.requestManager.getCurentTime().beginningOfTheDay)
                                                            }
                                                        }
                                                    }
                                                                                                    
                                                    GoogleNewResponse.countPage += 1
                                                    DispatchQueue.main.async {
                                                        
                                                        do {
                                                            self.dataStoreg = try managedContext.fetch(fatchRequest) as? [NSManagedObject]
                                                            self.dataManager.retriveData()
                                                        } catch {
                                                            print(error)
                                                        }
                                                        self.newsCollectionView.reloadData()
                                                    }
                })
            }
            //Дописать проверку дня
        } else {
            do {
                self.dataStoreg = try managedContext.fetch(fatchRequest) as? [NSManagedObject]
                self.dataManager.retriveData()
            } catch {
                print(error)
            }
        }
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 3)
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(pauseTimer))
        view.addGestureRecognizer(hold)
        
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        
        self.newsCollectionView.register(UINib.init(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardID")
    }

    func updateUserInterface() {
        switch Network.reachability.status {
        case .unreachable:
            view.backgroundColor = .red
        case .wifi:
            view.backgroundColor = .green
        case .wwan:
            view.backgroundColor = .yellow
        }
        
        if !Network.reachability.isReachable {
            progressTimer.invalidate()
            let alert = UIAlertController(title: nil, message: " No internet connection, \nplease wait...", preferredStyle: .alert)
        
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
        
        } else {
            newsCollectionView.reloadData()
            dismiss(animated: false, completion: nil)
        }
    }
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    @objc
    func pauseTimer(_ gestureRecognizer: UILongPressGestureRecognizer) {
        progressTimer.invalidate()
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            progressTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
        }
    }
    
    @objc
    func updateProgressView() {
        
        progress += progressSteps
        progressView.setProgress(progress, animated: true)
        
        if progress >= 1.0
        {
            progressTimer.invalidate()
            progressView.progress = 0.0
            progress = 0.0
            stopTimer()
            scrollToNextCell()
        }
    }
    
    func goToAnotherScreen(indexNews: Int) {
        stopTimer()
        
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailedDescriptionViewControllerID") as? DetailedDescriptionViewController {
            vc.article = dataStoreg?[indexNews].value(forKey: "title") as? String
            vc.imageUrl = dataStoreg?[indexNews].value(forKey: "urlToImage") as? String
            vc.url = dataStoreg?[indexNews].value(forKey: "url") as? String
            vc.articleDescription = dataStoreg?[indexNews].value(forKey: "descriptionNews") as? String
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    func scrollToNextCell() {
  
        print("data storeg count: \(dataStoreg?.count)")
        print("curent news cell: \(currentNewsCell)")
        
        if let count = dataStoreg?.count, currentNewsCell == count - 1 {
           
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fatchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                self.requestManager.gettingNews(fromTime: self.requestManager.getCurentTime().beginningOfTheDay, toTime: self.requestManager.getCurentTime().currentTimeAndDate, page: "\(GoogleNewResponse.countPage)") { (request) in
                    
                    DispatchQueue.main.async {
                        if let newsArray = request.articles {
                            for news in newsArray {
                                self.dataManager.createData(newsArray: news, images: nil, countPage: "\(GoogleNewResponse.countPage)", currentDate: self.requestManager.getCurentTime().beginningOfTheDay)
                            }
                        }
                        do {
                            self.dataStoreg = try managedContext.fetch(fatchRequest) as? [NSManagedObject]
//                            self.dataManager.retriveData()
                            //self.newsCollectionView.reloadData()
                        } catch {
                            print(error)
                        }
                        self.newsCollectionView.reloadData()
                        self.newsCollectionView.scrollToItem(at: IndexPath(item: self.currentNewsCell + 1, section: 0), at: .centeredHorizontally, animated: true)
                        self.resetTimer()
                        self.currentNewsCell += 1
                        GoogleNewResponse.countPage += 1
                    }
 
                    //self.newsCollectionView.reloadData()
                    
//                    self.currentNewsCell += 1
//                    GoogleNewResponse.countPage += 1
                    
                }
            }
        } else {
            self.newsCollectionView.scrollToItem(at: IndexPath(item: self.currentNewsCell + 1, section: 0), at: .centeredHorizontally, animated: true)
            self.resetTimer()
            self.currentNewsCell += 1
        }
    }
    
    func scrollToPreviousCell() {
        newsCollectionView.scrollToItem(at: IndexPath(item: currentNewsCell - 1, section: 0), at: .centeredHorizontally, animated: true)
        resetTimer()
        self.currentNewsCell -= 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
        newsCollectionView.reloadData()
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStoreg?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardID", for: indexPath) as! CardCollectionViewCell
        
        cell.titleArticle.text = dataStoreg?[indexPath.row].value(forKey: "title") as? String
        
            if let imageURL = dataStoreg?[indexPath.row].value(forKey: "urlToImage") as? String, let url = URL(string: imageURL)  {
            cell.imageArticle.load(url: url) { (image) in
                cell.imageArticle.image = self.blure.blurImage(image: image)
            }
        }
        
        cell.delegate = self
        cell.goToNextVCDelegate = self
        
        let layer = cell.moreInformationOutlet.layer.sublayers!
        
        for layers in layer  {
            if layers.name == "Pulselayers" {
                layers.removeFromSuperlayer()
            }
        }
        
        //MARK: Create pulse animation
        let pulse = PulseAnimation()
        let pulsePositionX = cell.moreInformationOutlet.bounds.midX
        let pulsePositionY = cell.moreInformationOutlet.bounds.midY
        
        pulse.createPulse(position: CGPoint(x: pulsePositionX, y: pulsePositionY))
        
        for i in 0..<pulse.pulseLayers.count {
            cell.moreInformationOutlet.layer.insertSublayer(pulse.pulseLayers[i], at: 0)
        }
        
        if let publisherName = (dataStoreg?[indexPath.row].value(forKey: "id") as? String) {
            cell.moreInformationOutlet.setImage(cell.logDefinition(newsResource: publisherName), for: .normal)
        }
        
        return cell
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if currentNewsCell == 0 && (scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0) {
            
            self.stopTimer()
            DispatchQueue.global(qos: .userInteractive).async {
                self.requestManager.gettingNews(fromTime: self.requestManager.getCurentTime().beginningOfTheDay,
                                                toTime: self.requestManager.getCurentTime().currentTimeAndDate,
                                                page:  "\(GoogleNewResponse.countPage)", using: { (request) in
                                                    DispatchQueue.main.async {
                                                        if let article = request.articles {
                                                            self.dataManager.deleteAllData("News")
                                                            for data in article {
                                                                self.dataManager.createData(newsArray: data, images: nil, countPage: "\(GoogleNewResponse.countPage)", currentDate: self.requestManager.getCurentTime().beginningOfTheDay)
                                                            }
                                                        }
                                                    }
                                                    DispatchQueue.main.async {
                                                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                                                        let managedContext = appDelegate.persistentContainer.viewContext
                                                        let fatchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "News")
                                                        
                                                        do {
                                                            self.dataStoreg = try managedContext.fetch(fatchRequest) as? [NSManagedObject]
                                                            self.resetTimer()
                                                            self.newsCollectionView.reloadData()
                                                            self.dataManager.retriveData()
                                                        } catch {
                                                            print(error)
                                                        }
                                                        self.newsCollectionView.reloadData()
                                                    }
                })
            }
        }
        
        delegetSettingTimer?.stopTimer()
        
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).x > 0) {
            scrollToPreviousCell()
        }
        else {
            scrollToNextCell()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        resetTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var visibleRect = CGRect()
        
        visibleRect.origin = newsCollectionView.contentOffset
        visibleRect.size = newsCollectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = newsCollectionView.indexPathForItem(at: visiblePoint) else { return }
        
        self.currentNewsCell = indexPath.row
        
    }
}

extension MainViewController: TimerOptions {
    
    func startTimer() {
        progress = 0.0
        progressTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        progress = 0.0
        DispatchQueue.main.async {
            self.progressView.setProgress(0, animated: false)
            self.progressTimer.invalidate()
        }
    }
    
    func resetTimer() {
        progressTimer.invalidate()
        DispatchQueue.main.async {
            self.progressView.setProgress(0, animated: false)
        }
        progress = 0.0
        progressTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = UIScreen.main.bounds.width
        let itemHeight = UIScreen.main.bounds.height
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
