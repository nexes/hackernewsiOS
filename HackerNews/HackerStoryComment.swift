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
    private let dateFormatter = DateFormatter()
    private var storyComments = [comment]()
    private var session: URLSession!
    
    
    struct comment {
        var author: String
        var parentid: Int
        var commentText: String
        var time: String
    }
    
    var commentCount: Int {
        return storyComments.count
    }
    
    
    init(withCommentIDs ids: [Int]) {
        super.init()
        
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        for i in 0..<ids.count {
            fetchComment(byID: ids[i])
        }
    }
    
    subscript(index: Int) -> comment {
        return storyComments[index]
    }
    
    private func fetchComment(byID id: Int) {
        guard let url = URL(string: baseURL + "\(id).json") else {
            print("Error fetchComment URL")
            return
        }
        
        let dataTask = session.dataTask(with: url)
        dataTask.resume()
    }
    
    //MARK: - URLSession delegate functions
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("Story comment task completed with error: \(error.debugDescription)")
        }
        
        session.finishTasksAndInvalidate()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let jsonString = String(bytes: data, encoding: .utf8) else {
            print("Error comment urlSession jsonString")
            return
        }
        
        do {
            guard let respObj = try JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!, options: .allowFragments) as? [String: Any] else {
                print("Error comment urlSession JSONSerialization")
                return
            }
            
            let time = respObj["time"] as? Int ?? 0
            let text = respObj["text"] as? String ?? ""
            let childComments = respObj["kids"] as? [Int] ?? [Int]()
            
            let cmt = comment(author: respObj["by"] as? String ?? "",
                              parentid: respObj["id"] as? Int ?? 0,
                              commentText: text.escapeXML(),
                              time: dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time))))
            
            //add the parent comment
            storyComments.append(cmt)
            
            //add any child comments if any
            if childComments.count > 0 {
                for id in childComments {
                    fetchComment(byID: id)
                }
            }
            
        } catch let err as NSError {
            print("Story comment error \(err.debugDescription)")
        }
    }
}

extension String {
    func escapeXML() -> String {
        guard let newString = (self as NSString).removingPercentEncoding else {
            return self
        }
        
        //ugh
        return newString.replacingOccurrences(of: "&#x27;", with: "'")
                        .replacingOccurrences(of: "&#x2F;", with: "/")
                        .replacingOccurrences(of: "&quot;", with: "\"")
                        .replacingOccurrences(of: "&gt;", with: ">")
                        .replacingOccurrences(of: "&lt;", with: "<")
                        .replacingOccurrences(of: "<p>", with: "\n")
    }
}
