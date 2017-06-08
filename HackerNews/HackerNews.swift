//
//  HackerNews.swift
//  HackerNews
//
//  Created by Joe Berria on 5/3/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import Foundation


protocol HackerNewsStoriesDelegate {
    func hackerNewsAllStoriesCompleted()
    func hackerNews(singleStoryCompleted story: HackerNewsStory)
    func hackerNews(updatedStoryCompleted story: HackerNewsStory)
}


class HackerNews: NSObject, URLSessionDataDelegate {
    private let baseURL = "https://hacker-news.firebaseio.com/v0/"
    
    private var foundNewStory = false
    private var storyDisplayCount = 10
    private var startStoryDisplay = 0
    private var storyIDNumbers = [Int]()
    private var sessionTasks = [Int: String]()
    private var sessionValid = true
    
    private var session: URLSession?
    private var hackerStory: HackerNewsStory?
    public var delegate: HackerNewsStoriesDelegate?


    init(withDelegate delegate: HackerNewsStoriesDelegate? = nil) {
        if delegate != nil {
            self.delegate = delegate
        }

        super.init()
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }

    // MARK: - fetching new and updated stories methods
    
    func fetchTopStories(limitNumberOfStories limit: Int) {
        storyDisplayCount = limit
        startNewSessionTask(withURLString: baseURL + "topstories.json", taskName: "story IDs")
    }

    func fetchNewStories(limitNumberOfStories limit: Int) {
        storyDisplayCount = limit
        startNewSessionTask(withURLString: baseURL + "newstories.json", taskName: "story IDs")
    }

    func fetchBestStories(limitNumberOfStories limit: Int) {
        storyDisplayCount = limit
        startNewSessionTask(withURLString: baseURL + "beststories.json", taskName: "story IDs")
    }

    func showAdditionalStories(count: Int) {
        startStoryDisplay += storyDisplayCount

        if startStoryDisplay + storyDisplayCount <= storyIDNumbers.count - 1 {
            loadStoriesFromFromRange(from: startStoryDisplay, to: startStoryDisplay + storyDisplayCount)

        } else {
            loadStoriesFromFromRange(from: startStoryDisplay, to: storyIDNumbers.count - 1)
        }
    }
    
    
    // MARK: - urlSession delegate methods
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let err = error {
            print("didBecomeInvalidWithError with error \(err.localizedDescription)")
        }

        sessionValid = false
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let taskType = sessionTasks.removeValue(forKey: task.taskIdentifier) {
            if taskType == "single story" && foundNewStory, let newStory = hackerStory {
                foundNewStory = false

                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.hackerNews(singleStoryCompleted: newStory)
                }
            }
        }

        if sessionTasks.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.hackerNewsAllStoriesCompleted()
            }

            session.finishTasksAndInvalidate()
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
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
                    if let itemID = Int(item) {
                        storyIDNumbers.append(itemID)
                    }
                }

                if storyIDNumbers.isEmpty == false {
                    sessionTasks.removeValue(forKey: dataTask.taskIdentifier)
                    loadStoriesFromFromRange(from: 0, to: storyDisplayCount)
                }
            }

        } else if sessionTasks[dataTask.taskIdentifier] == "single story" {
            if let respString = String(bytes: data, encoding: .utf8),
                let newStory = HackerNewsStory(withJsonString: respString) {

                foundNewStory = true
                hackerStory = newStory
            }
        }
    }


    // MARK: - private functions starting url tasks
    
    private func addNewSessionTask(_ taskID: Int, withName name: String) {
        sessionTasks[taskID] = name
    }

    private func startNewSessionTask(withURLString url: String, taskName: String) {
        if sessionValid == false {
            session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            sessionValid = true
        }

        if let url = URL(string: url), let task = session?.dataTask(with: url) {
            addNewSessionTask(task.taskIdentifier, withName: taskName)
            task.resume()
        }
    }

    private func loadStoriesFromFromRange(from start: Int, to end: Int) {
        let start = min(start, end)

        for i in start..<end {
            let url = baseURL + "item/\(storyIDNumbers[i]).json"
            startNewSessionTask(withURLString: url, taskName: "single story")
        }
    }
}




