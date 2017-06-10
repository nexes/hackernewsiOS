//
//  FavoriteStoryListViewControllerTableViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 6/1/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit
import CoreData


class FavoriteStoryListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    private var fetchedData: NSFetchedResultsController<Story>?
    private var favoriteCountKey = "favoriteCount"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest: NSFetchRequest<Story> = Story.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        fetchedData = NSFetchedResultsController<Story>(fetchRequest: fetchRequest,
                                                        managedObjectContext: AppDelegate.mainViewContext,
                                                        sectionNameKeyPath: nil,
                                                        cacheName: nil)
        fetchedData?.delegate = self
        
        do {
            try fetchedData?.performFetch()
        } catch {
            print("error performFetch \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.title = "Favorites"
        navigationController?.navigationBar.barTintColor = UIColor(red: 81/255, green: 144/255, blue: 145/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedData?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as? FavoriteStoryViewCell else {
            return UITableViewCell()
        }
        
        let story = fetchedData?.object(at: indexPath)
        cell.story = story
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "\u{274C} \nDelete", handler:
        {[weak self] (action, indexPath) in
            let context = AppDelegate.mainViewContext
            let standardDefault = UserDefaults.standard
            let barItem = self?.tabBarController?.tabBar.items?[3]
            
            context.perform {
                if let story = self?.fetchedData?.object(at: indexPath) {
                    context.delete(story)
                    
                    do {
                        try context.save()
                    } catch {
                        print("error saving after deletion: \(error)")
                    }
                }
            }
            
            var count = standardDefault.integer(forKey: (self?.favoriteCountKey)!)
            count -= 1
            
            barItem?.badgeValue = "\(count)"
            standardDefault.set(count, forKey: (self?.favoriteCountKey)!)
        })
        
        return [deleteAction]
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.automatic)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
            
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let story = fetchedData?.object(at: tableView.indexPathForSelectedRow!)
        
        if let tabBarVC = segue.destination as? UITabBarController {
            if let storyVC = tabBarVC.viewControllers?[0] as? StoryViewController {
                storyVC.favoriteStory = story
            }
        }
    }
}
