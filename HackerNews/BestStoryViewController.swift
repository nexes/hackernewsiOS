//
//  BestStoryViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/16/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit


class BestStoryViewController: UITableViewController, HackerNewsStoriesDelegate {
    private var bestStories = [HackerNewsStory]()
    private var hackerNews: HackerNews!
    private var storyDisplayCount = 30
    private var storiesAreLoading = true
    private var favoriteCountKey = "favoriteCount"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        hackerNews = HackerNews(withDelegate: self)
        hackerNews.fetchBestStories(limitNumberOfStories: storyDisplayCount)
        
        updateFavoriteBadge()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "Best"
        navigationController?.navigationBar.barTintColor = UIColor(red: 104/255, green: 216/255, blue: 141/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Hacker News story delegates
    
    func hackerNews(allStoriesCompleted topStories: [HackerNewsStory]) {
        storiesAreLoading = false
    }
    
    func hackerNews(singleStoryCompleted story: HackerNewsStory) {
        bestStories.append(story)
        tableView.insertRows(at: [IndexPath(row: bestStories.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
    }
    
    func hackerNews(updatedStoryCompleted story: HackerNewsStory) {
        //TODO
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bestStories.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let storyAtRow = bestStories[indexPath.row]
        let storyContent: Any = storyAtRow.Url ?? storyAtRow.Text ?? "" // kind of a hack but it works, if there is no url, use the text, if no text, empty string
        let shareViewController = UIActivityViewController(activityItems: [storyAtRow.Title!, storyContent], applicationActivities: nil)
        
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Share", handler:
        {[weak self] (action, indexPath) in
            
            shareViewController.excludedActivityTypes = [
                UIActivityType.airDrop,
                UIActivityType.openInIBooks,
                UIActivityType.assignToContact,
                UIActivityType.postToVimeo,
                UIActivityType.saveToCameraRoll
            ]
            
            self?.navigationController?.present(shareViewController, animated: true, completion: nil)
            self?.isEditing = false
        })
        
        let favoriteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Favorite", handler:
        { [weak self] (action, indexPath) -> Void in
            let context = AppDelegate.mainViewContext
            
            context.perform {
                let newsStory = self?.bestStories[indexPath.row]
                let story = Story(context: context)
                
                story.author = newsStory?.Author
                story.title = newsStory?.Title
                story.url = story.toString(fromURL: (newsStory?.Url)!)
                story.date = story.toNSDate(fromDate: (newsStory?.Time)!)
                story.score = story.toInt32(fromInt: (newsStory?.Score)!)
                story.commentIDs = story.toData(fromIntArray: (newsStory?.CommentIDs)!)
                
                do {
                    if context.hasChanges {
                        try context.save()
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            self?.updateFavoriteBadge(by: 1)
            self?.isEditing = false //closes the editor menu
        })
        
        shareAction.backgroundColor = UIColor.lightGray
        favoriteAction.backgroundColor = UIColor(red: 71/255, green: 198/255, blue: 237/255, alpha: 1)
        
        return [favoriteAction, shareAction]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let bestCell = tableView.dequeueReusableCell(withIdentifier: "bestStoryCell", for: indexPath) as? BestStoryViewCell {
            let story = bestStories[indexPath.row]
            bestCell.hackerStory = story
            
            return bestCell
        }
        
        //shouldn't get here
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        if storiesAreLoading == false && indexPath.row >= rowCount - 1 {
            storiesAreLoading = true
            hackerNews.showAdditionalStories(count: storyDisplayCount)
        }
    }
    
    // MARK: - update favorite badge
    
    private func updateFavoriteBadge(by count: Int? = nil) {
        let standardDefault = UserDefaults.standard
        let barItem = tabBarController?.tabBar.items?[3]
        var currentCount = standardDefault.integer(forKey: favoriteCountKey)
        
        if let newCount = count{
            currentCount += newCount
            standardDefault.set(currentCount, forKey: favoriteCountKey)
        }
        
        barItem?.badgeValue = "\(currentCount)"
    }

    // MARK: - Segue navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabView = segue.destination as? UITabBarController
        
        if let storyView = tabView?.viewControllers?[0] as? StoryViewController {
            let story = bestStories[(tableView.indexPathForSelectedRow?.row)!]
            storyView.hackerStory = story
        }
    }
}
