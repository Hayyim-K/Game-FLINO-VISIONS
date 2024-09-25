//
//  MenuViewController.swift
//  Game
//
//  Created by Hayyim on 13/09/2024.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var lastScoreLabel: UILabel!
    
    private let uD = StorageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userInfo = uD.fatchStatistics()
        
        bestScoreLabel.text = "BEST SCORE: \(userInfo.bestScore)"
        lastScoreLabel.text = "LAST SCORE: \(userInfo.score)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userInfo = uD.fatchStatistics()
        
        bestScoreLabel.text = "BEST SCORE: \(userInfo.bestScore)"
        lastScoreLabel.text = "LAST SCORE: \(userInfo.score)"
    }
    

    @IBAction func playButtonPressed() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
