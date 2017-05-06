//
//  HackerNews.swift
//  HackerNews
//
//  Created by Joe Berria on 5/3/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import Foundation


public struct HackerNewsStory {
  // I don't like all these variables
  private var type: String?
  private var title: String?
  private var author: String?
  private var score: Int?
  private var time: Date?
  private var url: URL?
  private var text: String?
  private var commentIDs: [Int]?
  
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
      return commentIDs?.count ?? 0
    }
  }
  
  // No one outside of this file should beable to create one of these. just call their variable getters
  fileprivate init(withJsonString jsonString: String) {
    convertStringToJSON(jsonString)
  }
  
  private mutating func convertStringToJSON(_ jsonString: String) {
    do {
      let jsonObj = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!)
      if let storyObj = jsonObj as? [String: Any] {
        author = storyObj["by"] as? String
        score = storyObj["score"] as? Int
        time = Date(timeIntervalSince1970: storyObj["time"] as! Double) // umm
        title = storyObj["title"] as? String
        type = storyObj["type"] as? String
        commentIDs = storyObj["kids"] as? [Int]
        
        //some post wont link to an artical, no URL
        if let url = storyObj["url"] as? String {
          self.url = URL(string: url) //umm check if https exists first
        }
        
        //some post will have text (artical) insead of an url
        if let text = storyObj["text"] as? String {
          self.text = text
        }
      }
      
    } catch let err as NSError {
      print("convertStringToJSON error \(err.debugDescription)")
    }
  }
}


protocol HackerNewsStoriesDelegate {
  func hackerNews(allStoriesCompleted topStories: [HackerNewsStory])
  func hackerNews(singleStoryCompleted story: HackerNewsStory)
}


class HackerNews: NSObject, URLSessionDataDelegate {
  private var baseURL = "https://hacker-news.firebaseio.com/v0/"
  private var fetchStoryLimit: Int
  private var storyIDNumbers: [Int]
  private var sessionTasks: [Int: String]
  private var session: URLSession?
  private var stories: [HackerNewsStory]?
  public var delegate: HackerNewsStoriesDelegate?
  
  init(withDelegate delegate: HackerNewsStoriesDelegate? = nil) {
    if delegate != nil {
      self.delegate = delegate
    }
    fetchStoryLimit = 10
    storyIDNumbers = [Int]()
    sessionTasks = [Int: String]()
    stories = [HackerNewsStory]()
    super.init()
    
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.allowsCellularAccess = true
    sessionConfig.urlCache = nil
    
    session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
  }
  
  func fetchTopStories(limitNumberOfStories limit: Int) {
    fetchStoryLimit = limit
    startNewSessionTask(withURLString: baseURL + "topstories.json", taskName: "top stories")
  }
  
  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    if let err = error {
      print("didBecomeInvalidWithError with error \(err.localizedDescription)")
    }
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let taskType = sessionTasks.removeValue(forKey: task.taskIdentifier) {
      if taskType == "single story", let newStory = stories?.last {
        //our delegate will probably update UI, so call it on the main thread
        DispatchQueue.main.async { [weak self] in
          self?.delegate?.hackerNews(singleStoryCompleted: newStory)
        }
      }
    }
    
    if sessionTasks.isEmpty {
      if (stories != nil) {
        //our delegate will probably update UI, so call it on the main thread
        DispatchQueue.main.async { [weak self] in
          self?.delegate?.hackerNews(allStoriesCompleted: (self?.stories)!)
        }
      }
      session.finishTasksAndInvalidate()
    }
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    if sessionTasks[dataTask.taskIdentifier] == "top stories" {
      if var dataString = String(bytes: data, encoding: .utf8) {
        //remove "]" and "[" if present
        if let openBraceChar = dataString.characters.index(of: "[") {
          dataString.remove(at: openBraceChar)
        }
        if let closeBraceChar = dataString.characters.index(of: "]") {
          dataString.remove(at: closeBraceChar)
        }
        
        let stringArray = dataString.components(separatedBy: ",")
        for item in stringArray {
          storyIDNumbers.append(Int(item)!)
        }
        
        if storyIDNumbers.isEmpty == false {
          loadStoriesFromFromRange(from: 0, to: fetchStoryLimit)
        }
      }
      
    } else if sessionTasks[dataTask.taskIdentifier] == "single story" {
      if let respString = String(bytes: data, encoding: .utf8) {
        stories?.append(HackerNewsStory(withJsonString: respString))
      }
    }
  }
  
  private func addNewSessionTask(_ taskID: Int, withName name: String) {
    sessionTasks[taskID] = name
  }
  
  private func startNewSessionTask(withURLString url: String, taskName: String) {
    if let url = URL(string: url), let task = session?.dataTask(with: url) {
      addNewSessionTask(task.taskIdentifier, withName: taskName)
      task.resume()
    }
  }
  
  private func loadStoriesFromFromRange(from start: Int, to end: Int) {
    for i in start..<end {
      let url = baseURL + "/item/\(storyIDNumbers[i]).json"
      startNewSessionTask(withURLString: url, taskName: "single story")
    }
  }
}




