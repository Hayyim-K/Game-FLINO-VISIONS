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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userInfo = uD.fatchStatistics()
        
        bestScoreLabel.text = "BEST SCORE: \(userInfo.bestScore)"
        lastScoreLabel.text = "LAST SCORE: \(userInfo.score)"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func playButtonPressed() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
