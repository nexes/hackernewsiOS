//
//  HackerNewsStory.swift
//  HackerNews
//
//  Created by Joe Berria on 5/8/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import Foundation


struct HackerNewsStory {
    // I don't like all these variables
    private var type: String?
    private var title: String?
    private var author: String?
    private var score: Int?
    private var commentCount: Int?
    private var time: Date?
    private var url: URL?
    private var text: String?
    private var kids: [Int]?
    
    private var dateFormatter = DateFormatter()
    
    
    public var Title: String? {
        get {
            return title
        }
    }
    
    public var Author: String? {
        get {
            return author
        }
    }
    
    public var Time: Date? {
        get {
            return time
        }
    }
    
    public var Url: URL? {
        get {
            return url
        }
    }
    
    public var Text: String? {
        get {
            return text
        }
    }
    
    public var Score: Int {
        get {
            return score ?? 0
        }
    }
    
    public var CommentCount: Int {
        get {
            return commentCount ?? 0
        }
    }
    
    public var CommentIDs: [Int] {
        get {
            return kids ?? [Int]()
        }
    }
    
    
    
    init?(withJsonString jsonString: String) {
        if (!convertStringToJSON(jsonString)) {
            return nil
        }
    }
    
    func formatedStoryDate() -> String {
        if time != nil {
            return DateFormatter.localizedString(from: time!, dateStyle: .short, timeStyle: .short)
            
        } else  {
            return "-"
        }
    }
    
    func comments() -> HackerStoryComments? {
        if let comments = kids {
            return HackerStoryComments(withCommentIDs: comments)
        }
        
        return nil
    }
    
    private mutating func convertStringToJSON(_ jsonString: String) -> Bool {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!)
            if let storyObj = jsonObj as? [String: Any] {
                author = storyObj["by"] as? String
                score = storyObj["score"] as? Int
                time = Date(timeIntervalSince1970: storyObj["time"] as! Double) // umm
                title = storyObj["title"] as? String
                type = storyObj["type"] as? String
                kids = storyObj["kids"] as? [Int]
                commentCount = storyObj["descendants"] as? Int
                
                if let url = storyObj["url"] as? String {
                    self.url = URL(string: url)
                }
                
                if let text = storyObj["text"] as? String {
                    self.text = text
                }
            }
            
        } catch let err as NSError {
            print("convertStringToJSON error \(err.debugDescription)")
            
            return false
        }
        
        return true
    }
}
