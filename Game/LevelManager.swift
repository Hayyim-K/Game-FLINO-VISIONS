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
    isGravityDiviation: Bool = false,
    isFixedGravity: Bool = true,
    xGravity: Double = 10,
    yGravity: Double = 10,
    wildFireRestoreInterval: Double = 30,
    maxCloudsInRange: Int,
    minCloudsInRange: Int = 2,
    score: Int = 0,
    level: Int = 0,
    evaPrice: Int = 50,
    tFPrice: Int = 33,
    cloudCollisionPrice: Int = 1,
    stormCloudCollisionPrice: Int = 2,
    deviationByX: Int = 100,
    deviationByY: Int = 1000,
    bgColor: UIColor = #colorLiteral(red: 0.702839592, green: 0.1938713611, blue: 0.9012210876, alpha: 0.55)
    ) {
        
        if let scene = SKScene(fileNamed: sceneName) as? BaseLevelScene {
            
            scene.dropDiameter = dropDiameter
            scene.isGravityDiviation = isGravityDiviation
            scene.isFixedGravity = isFixedGravity
            scene.xGravity = xGravity
            scene.yGravity = yGravity
            scene.wildFireRestoreInterval = wildFireRestoreInterval
            scene.maxCloudsInRange = maxCloudsInRange
            scene.minCloudsInRange = minCloudsInRange
            scene.score = score
            scene.level = level
            scene.evaPrice = evaPrice
            scene.tFPrice = tFPrice
            scene.cloudCollisionPrice = cloudCollisionPrice
            scene.stormCloudCollisionPrice = stormCloudCollisionPrice
            scene.deviationByX = deviationByX
            scene.deviationByY = deviationByY
            scene.bgColor = bgColor
            
            scene.backgroundColor = .clear
            
            scene.scaleMode = .aspectFit
            
            view.presentScene(
                scene,
                transition: SKTransition.fade(withDuration: 2)
            )
        }
    }
    
}
