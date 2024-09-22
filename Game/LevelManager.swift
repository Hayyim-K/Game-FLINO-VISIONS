//
//  LevelManager.swift
//  Game
//
//  Created by Hayyim on 19/09/2024.
//

import SpriteKit

class LevelManager {
    static let shared = LevelManager()
    private init() {}
    
    func loadLevel(
        sceneName: String,
        into view: SKView,
        with dropDiameter: CGFloat,
        maxCloudsInRange: Int,
        minCloudsInRange: Int = 2,
        score: Int = 0,
        level: Int = 0
    ) {
        
        if let scene = SKScene(fileNamed: sceneName) as? BaseLevelScene {
            
            scene.dropDiameter = dropDiameter
            scene.maxCloudsInRange = maxCloudsInRange
            scene.minCloudsInRange = minCloudsInRange
            scene.score = score
            scene.level = level
            
            scene.scaleMode = .aspectFit
            
            view.presentScene(
                scene,
                transition: SKTransition.fade(withDuration: 2)
            )
        }
    }
    
}
