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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedData?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
        let story = fetchedData?.object(at: indexPath)
        
        cell.textLabel?.text = story?.title
        cell.detailTextLabel?.text = story?.author
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "delete", handler:
        {[weak self] (action, indexPath) in
            let context = AppDelegate.mainViewContext
            
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
        })
        
        return [deleteAction]
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.automatic)
            
        case .delete:
            print("didChange delete called")
            tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
            
        default:
            break
        }
    }
}
