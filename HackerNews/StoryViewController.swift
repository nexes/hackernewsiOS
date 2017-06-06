//
//  StoryViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/4/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit
import WebKit

class StoryViewController: UIViewController, UITabBarControllerDelegate {
    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var storyAuthorLabel: UILabel!
    @IBOutlet weak var storyScoreLabel: UILabel!
    @IBOutlet weak var displayStoryView: UIView!
    
    private var wkViewConfiguration: WKWebViewConfiguration!
    private var hackerStoryComments: HackerStoryComments!
    
    var hackerStory: HackerNewsStory? {
        didSet {
            hackerStoryComments = hackerStory?.comments()
        }
    }
    
    var favoriteStory: Story? {
        didSet {
            if let commentData = favoriteStory?.commentIDs {
                hackerStoryComments = favoriteStory?.storyComments(fromData: commentData)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
        navigationController?.navigationBar.tintColor = UIColor.white
        
        wkViewConfiguration = WKWebViewConfiguration()
        wkViewConfiguration.ignoresViewportScaleLimits = true
        wkViewConfiguration.allowsInlineMediaPlayback = true
        
        if (favoriteStory != nil) {
            updateUI(withStory: favoriteStory)
            
        } else {
            updateUI()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 1 {
            guard let commentView = viewController as? CommentListViewController else {
                return
            }
            
            commentView.storyComments = hackerStoryComments
        }
    }
    
    private func updateUI(withStory story: Story? = nil) {
        if (story != nil) {
            storyTitleLabel.text = story?.title
            storyAuthorLabel.text = story?.author
            storyScoreLabel.text = "score \(story?.score ?? 0)"
            
            if let url = URL(string: (story?.url)!) {
                setupURLView(with: url)
            }
            
        } else if (hackerStory != nil) {
            storyTitleLabel.text = hackerStory?.Title
            storyAuthorLabel.text = hackerStory?.Author
            storyScoreLabel.text = "score \(story?.score ?? 0)"
            
            if (hackerStory?.Url != nil) {
                setupURLView(with: (hackerStory?.Url)!)
                
            } else if (hackerStory?.Text != nil) {
                setupTextView()
            }
        }
    }
    
    private func setupURLView(with url: URL) {
        let webView = WKWebView(frame: view.frame, configuration: wkViewConfiguration)
        webView.load(URLRequest(url: url))
        
        displayStoryView.addSubview(webView)
    }
    
    private func setupTextView() {
        let textView = UITextView(frame: displayStoryView.frame)
        textView.text = hackerStory?.Text
        
        displayStoryView.addSubview(textView)
    }
}
