//
//  HackerNews.swift
//  HackerNews
//
//  Created by Joe Berria on 5/3/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import Foundation


protocol HackerNewsStoriesDelegate {
  func hackerNews(allStoriesCompleted topStories: [HackerNewsStory])
  func hackerNews(singleStoryCompleted story: HackerNewsStory)
}


class HackerNews: NSObject, URLSessionDataDelegate {
  private var baseURL = "https://hacker-news.firebaseio.com/v0/"
  private var foundNewStory = false
  private var fetchStoryLimit: Int
  private var storyIDNumbers: [Int]
  private var sessionTasks: [Int: String]
  private var session: URLSession?
  
  lazy private var topStories: [HackerNewsStory] = {
    return [HackerNewsStory]()
  }()
  
  lazy private var bestStories: [HackerNewsStory] = {
    return [HackerNewsStory]()
  }()

  lazy private var newStories: [HackerNewsStory] = {
    return [HackerNewsStory]()
  }()

  public var delegate: HackerNewsStoriesDelegate?
  
  
  init(withDelegate delegate: HackerNewsStoriesDelegate? = nil) {
    if delegate != nil {
      self.delegate = delegate
    }
    fetchStoryLimit = 10
    storyIDNumbers = [Int]()
    sessionTasks = [Int: String]()
    super.init()
    
    session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
  }
  
  func fetchTopStories(limitNumberOfStories limit: Int) {
    fetchStoryLimit = limit
    startNewSessionTask(withURLString: baseURL + "topstories.json", taskName: "story IDs")
  }
  
  func fetchNewStories(limitNumberOfStories limit: Int) {
    fetchStoryLimit = limit
    startNewSessionTask(withURLString: baseURL + "newstories.json", taskName: "story IDs")
  }
  
  func fetchBestStories(limitNumberOfStories limit: Int) {
    fetchStoryLimit = limit
    startNewSessionTask(withURLString: baseURL + "beststories.json", taskName: "story IDs")
  }
  
  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    if let err = error {
      print("didBecomeInvalidWithError with error \(err.localizedDescription)")
    }
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let taskType = sessionTasks.removeValue(forKey: task.taskIdentifier) {
      if taskType == "single story" && foundNewStory, let newStory = topStories.last {
        foundNewStory = false
        DispatchQueue.main.async { [weak self] in
          self?.delegate?.hackerNews(singleStoryCompleted: newStory)
        }
      }
    }
    
    if sessionTasks.isEmpty {
      DispatchQueue.main.async { [weak self] in
        self?.delegate?.hackerNews(allStoriesCompleted: (self?.topStories)!)
      }
      
      session.finishTasksAndInvalidate()
    }
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    //top storise returns an array or IDs (Ints) not a json formated story
    if sessionTasks[dataTask.taskIdentifier] == "story IDs" {
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
      if let respString = String(bytes: data, encoding: .utf8),
         let newStory = HackerNewsStory(withJsonString: respString) {
      
        //check for duplicate stories: there is a better way to do this
        for story in topStories {
          if story.Title == newStory.Title {
            print("Found a dupicate story") //stop our delegate
            return
          }
        }
        
        foundNewStory = true
        topStories.append(newStory)
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




