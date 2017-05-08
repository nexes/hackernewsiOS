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
    
    session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
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
        DispatchQueue.main.async { [weak self] in
          self?.delegate?.hackerNews(singleStoryCompleted: newStory)
        }
      }
    }
    
    if sessionTasks.isEmpty {
      if (stories != nil) {
        DispatchQueue.main.async { [weak self] in
          self?.delegate?.hackerNews(allStoriesCompleted: (self?.stories)!)
        }
      }
      session.finishTasksAndInvalidate()
    }
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    //top storise returns an array or IDs (Ints) not a json formated story
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




