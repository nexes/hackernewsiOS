//
//  HNCommentViewController.swift
//  HackerNews
//
//  Created by Joe Berria on 5/8/17.
//  Copyright © 2017 Joe Berria. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
  @IBOutlet weak var testLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    testLabel.text = "This is just a test"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
}
