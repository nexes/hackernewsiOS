//
//  StoryListViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/3/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class StoryListViewController: UITableViewController, HackerNewsStoriesDelegate {
    private var hackerNews: HackerNews!
    private var hackerNewsStories = [HackerNewsStory]()
    private var storyDisplayCount = 30
    private var storiesAreLoading = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hackerNews = HackerNews(withDelegate: self)
        hackerNews.fetchTopStories(limitNumberOfStories: storyDisplayCount)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "Top"
        navigationController?.navigationBar.barTintColor = UIColor(red: 229/255, green: 165/255, blue: 36/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Hacker News delegate callbacks
    
    func hackerNews(allStoriesCompleted topStories: [HackerNewsStory]) {
        storiesAreLoading = false
    }
    
    func hackerNews(singleStoryCompleted story: HackerNewsStory) {
        hackerNewsStories.append(story)
        tableView.insertRows(at: [IndexPath(row: hackerNewsStories.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
    }
    
    func hackerNews(updatedStoryCompleted story: HackerNewsStory) {
        // if we already have this story, lets remove it and replace it with the updated version
    }
    
    
    // MARK: - TableView list refresh
    
    @IBAction func refreshStoryList(_ sender: UIRefreshControl) {
        print("refreshing list")
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hackerNewsStories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let hackerNewsCell = tableView.dequeueReusableCell(withIdentifier: "HNcell", for: indexPath) as? StoryListViewCell else {
            return UITableViewCell()
        }
        
        let story = hackerNewsStories[indexPath.row]
        
        hackerNewsCell.story = story
        return hackerNewsCell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowCount = tableView.numberOfRows(inSection: 0)
        
        if storiesAreLoading == false && indexPath.row >= rowCount - 1 {
            storiesAreLoading = true
            hackerNews.showAdditionalStories(count: storyDisplayCount)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let storyAtRow = hackerNewsStories[indexPath.row]
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
                let newsStory = self?.hackerNewsStories[indexPath.row]
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
            
            self?.isEditing = false //closes the editor menu
            let barItem = self?.tabBarController?.tabBar.items?[1]
            barItem?.badgeValue = "foo"
        })
        
        favoriteAction.backgroundColor = UIColor(red: 71/255, green: 198/255, blue: 237/255, alpha: 1)
        shareAction.backgroundColor = UIColor.lightGray
        
        return [favoriteAction, shareAction]
    }
    
    // MARK: - Segue preperation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarView = segue.destination as? UITabBarController {
            if let storyView = tabBarView.viewControllers?[0] as? StoryViewController { //need a better way to reference the view
                let hackerStory = hackerNewsStories[(tableView.indexPathForSelectedRow?.row)!]
                
                storyView.hackerStory = hackerStory
            }
        }
    }
}




