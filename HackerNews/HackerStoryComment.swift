//
//  HackerNewsComment.swift
//  HackerNews
//
//  Created by Joe Berria on 5/8/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import Foundation


class HackerStoryComments: NSObject, URLSessionDataDelegate {
  private let baseURL = "https://hacker-news.firebaseio.com/v0/item/"
  private var storyComments = [comment]()
  private var session: URLSession!
  
  private struct comment {
    var author: String
    var parentid: Int
    var commentText: String
    var time: Int
  }
  
  
  init(withCommentIDs ids: [Int]) {
    super.init()
    
    session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    
    for i in 0..<ids.count {
      fetchComment(byID: ids[i])
    }
  }
  
  private func fetchComment(byID id: Int) {
    if let url = URL(string: baseURL + "\(id).json") {
      let dataTask = session.dataTask(with: url)
      dataTask.resume()
    }
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if error != nil {
      print("Story comment task completed with error: \(error.debugDescription)")
    }
    
    session.finishTasksAndInvalidate()
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    if let jsonString = String(bytes: data, encoding: .utf8) {
      do {
        if let respObj = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as? [String: Any] {
          let cmt = comment(author: respObj["by"] as? String ?? "",
                            parentid: respObj["id"] as? Int ?? 0,
                            commentText: respObj["text"] as? String ?? "",
                            time: respObj["time"] as? Int ?? 0)
          
          storyComments.append(cmt)
        }
        
      } catch let err as NSError {
        print("Story comment error \(err.debugDescription)")
      }
    }
  }
}
