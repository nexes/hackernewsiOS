//
//  NewStoryListViewControllerTableViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/16/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit


class NewStoryListViewController: UITableViewController, HackerNewsStoriesDelegate {
    private let storyDisplayCount = 30
    private let favoriteCountKey = "favoriteCount"
    
    private var newStories = [HackerNewsStory]()
    private var hackerNews: HackerNews!
    private var storiesAreLoading = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        hackerNews = HackerNews(withDelegate: self)
        hackerNews.fetchNewStories(limitNumberOfStories: storyDisplayCount)
        
        updateFavoriteBadge()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "New"
        navigationController?.navigationBar.barTintColor = UIColor(red: 80/255, green: 169/255, blue: 237/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func refreshStories(_ sender: UIRefreshControl) {
        newStories.removeAll(keepingCapacity: true)
        tableView.reloadData()
        refreshControl?.beginRefreshing()
        
        hackerNews.fetchNewStories(limitNumberOfStories: storyDisplayCount)
    }
    
    // MARK: - Hacker News delegates
    
    func hackerNews(singleStoryCompleted story: HackerNewsStory) {
        if (refreshControl?.isRefreshing)! {
            refreshControl?.endRefreshing()
        }
        
        newStories.append(story)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: newStories.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }
    
    func hackerNews(updatedStoryCompleted story: HackerNewsStory) {
    }
    
    func hackerNewsAllStoriesCompleted() {
        storiesAreLoading = false
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newStories.count
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let storyAtRow = newStories[indexPath.row]
        let storyContent: Any = storyAtRow.Url ?? storyAtRow.Text ?? "" // kind of a hack but it works, if there is no url, use the text, if no text, empty string
        let shareViewController = UIActivityViewController(activityItems: [storyAtRow.Title!, storyContent], applicationActivities: nil)
        
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "\u{1F4E4} \nShare", handler:
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

        let favoriteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "\u{2B50} \nSave", handler:
        { [weak self] (action, indexPath) in
            let context = AppDelegate.mainViewContext
            
            context.perform {
                let newsStory = self?.newStories[indexPath.row]
                let story = Story(context: context)
                
                story.author = newsStory?.Author
                story.title = newsStory?.Title
                story.date = story.toNSDate(fromDate: (newsStory?.Time)!)
                story.url = story.toString(fromURL: (newsStory?.Url)!)
                story.score = story.toInt32(fromInt: (newsStory?.Score)!)
                story.commentIDs = story.toData(fromIntArray: (newsStory?.CommentIDs)!)
                
                do {
                    if context.hasChanges {
                        try context.save()
                    }
                    
                } catch {
                    print("NewStory save error \(error)")
                }
            }
            
            self?.updateFavoriteBadge(by: 1)
            self?.isEditing = false
        })
        
        shareAction.backgroundColor = UIColor.lightGray
        favoriteAction.backgroundColor = UIColor(red: 71/255, green: 198/255, blue: 237/255, alpha: 1)
        
        return [favoriteAction, shareAction]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let storyCell = tableView.dequeueReusableCell(withIdentifier: "newStoryCell", for: indexPath) as? NewStoryViewCell {
            let story = newStories[indexPath.row]
            storyCell.hackerStory = story
            
            return storyCell
        }
        
        //shouldn't get here
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        if storiesAreLoading == false && indexPath.row >= rowCount - 1 {
            storiesAreLoading = true
            hackerNews?.showAdditionalStories(count: storyDisplayCount)
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

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabView = segue.destination as? UITabBarController
        
        if let storyView = tabView?.viewControllers?[0] as? StoryViewController {
            let story = newStories[(tableView.indexPathForSelectedRow?.row)!]
            storyView.hackerStory = story
        }
    }
}
