//
//  Story.swift
//  HackerNews
//
//  Created by Joe Berria on 5/31/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import Foundation
import CoreData


class Story: NSManagedObject {
    
    func toString(fromURL url: URL) -> String {
        return url.absoluteString
    }
    
    func toNSDate(fromDate date: Date) -> NSDate {
        return date as NSDate
    }
    
    func toInt32(fromInt value: Int) -> Int32 {
        guard let newValue = Int32(exactly: value) else {
            return Int32(NSNumber(value: value))
        }
        
        return newValue
    }
    
    func toData(fromIntArray intArray: [Int]) -> NSData {
        return NSKeyedArchiver.archivedData(withRootObject: intArray) as NSData
    }
    
    func toIntArray(fromData data: NSData) -> [Int] {
        guard let commentIDs = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [Int] else {
            return [Int]()
        }
        
        return commentIDs
    }
    
    func storyComments(fromData data: NSData) -> HackerStoryComments {
        let commentData = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [Int]
        return HackerStoryComments(withCommentIDs: commentData!)
    }
}
