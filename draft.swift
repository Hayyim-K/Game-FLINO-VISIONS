//
//  draft.swift
//  Game
//
//  Created by Hayyim on 16/09/2024.
//

import Foundation

/*
 
 
 //    private func configureTF(_ x: Int, _ y: Int) {
 //        switch (x, y) {
 //        case (8, 0):
 //            deviationByX = 1000
 //            deviationByY = 100
 //        case (0, 8): gravityDirectionImage.image = UIImage(systemName: "arrow.down")
 //        case (8, 8): gravityDirectionImage.image = UIImage(systemName: "arrow.down.right")
 //        case (-8, -8): gravityDirectionImage.image = UIImage(systemName: "arrow.up.left")
 //        case (-8, 0): gravityDirectionImage.image = UIImage(systemName: "arrow.left")
 //        case (0, -8): gravityDirectionImage.image = UIImage(systemName: "arrow.up")
 //        default: gravityDirectionImage.image = UIImage(systemName: "arrow.down")
 //        }
 //    }
 //    ________________
 
 //            let dropDiameter: CGFloat
 //            let isGravityDiviation: Bool
 //            let xGravity: Double
 //            let yGravity: Double
 //            let maxCloudsInRange: Int
 //            let minCloudsInRange: Int
 //            let score: Int
 //
 //            let evaPrice: Int
 //            let tFPrice: Int
 //            let cloudCollisionPrice: Int
 //            let stormCloudCollisionPrice: Int
 //            let deviationByX: Int
 //            let deviationByY: Int
 //            let bgColor: UIColor
 
 
 
 __________
 
 else if bodyB.categoryBitMask == PhysicsCategory.drop,
 //                  bodyA.categoryBitMask == PhysicsCategory.defaultObject,
 //                  !collisionOccurred
 //        {
 //            print("there")
 //            print(collisionOccurred)
 //            setCollision(with: bodyA.node)
 //            UISelectionFeedbackGenerator().selectionChanged()
 ////            collisionOccurred.toggle()
 //        }
 
 
 
 __________
 // Load the SKScene from 'GameScene.sks'
 if let scene = SKScene(fileNamed: "Level1Scene") as? BaseLevelScene {
     
     scene.dropDiameter = 60
     scene.maxCloudsInRange = 6
     
     // Set the scale mode to scale to fit the window
     scene.scaleMode = .aspectFit
     // Present the scene
     view.presentScene(scene)
 }
 
 
 
 
 _____________________
 let kMinD: CGFloat = 600 / 30
 let kMaxD: CGFloat = 700 / 100
 
 let k: CGFloat = kMinD - (kMinD - kMaxD) * ((dropDiameter - 30) / 30)
 print(k, dropDiameter * k)
 
 
 ________
 
 //
 //  BaseLevelScene.swift
 //  Game
 //
 //  Created by Hayyim on 18/09/2024.
 //


 import AudioToolbox
 import SpriteKit
 import GameplayKit

 class BaseLevelScene: SKScene {
     
     private var drop: SKSpriteNode?
     
     private var dropDiameter: CGFloat = 80
     
     private var dropIsActive = false
     
     private var clouds = ["cloud-1", "cloud-2", "cloud-4", "cloud-5"]
     
     private var score = 0 {
         willSet {
             NotificationCenter.default.post(
                 name: Notification.Name("scoreHaschanged"),
                 object: nil,
                 userInfo: ["score": score, "level": level]
             )
         }
     }
     
     private var level = 0
     
     private var wildFiersCounter = 0 {
         didSet {
             if wildFiersCounter == 0 {
                 
                 dropIsActive = true
                 
                 NotificationCenter.default.post(
                     name: Notification.Name("levelCompleted"),
                     object: nil,
                     userInfo: ["score": score, "level": level]
                 )
             }
         }
     }
     
     
     override func didMove(to view: SKView) {
         
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(refreshDrop),
             name: Notification.Name("evaporationButtonTapped"),
             object: nil
         )
         
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(turbulenceFlowButtonTapped),
             name: Notification.Name("turbulenceFlowButtonTapped"),
             object: nil
         )
         
         physicsWorld.contactDelegate = self
         
         setBackGround()
         setBoard()
         setDrop()
         
     }
     
     private func setBackGround() {
         let background = SKSpriteNode(
             color: #colorLiteral(red: 0.702839592, green: 0.1938713611, blue: 0.9012210876, alpha: 0.55),
             size: CGSize(width: frame.width, height: frame.height)
         )
         background.position = CGPoint(x: frame.midX, y: frame.midY)
         background.zPosition = -100
         addChild(background)
     }
     
     private func setCloud(position: CGPoint) {
         let cloudType = clouds.randomElement()!
         let cloud = SKSpriteNode(imageNamed: cloudType)
         cloud.position = position
         
         cloud.size = CGSize(width: dropDiameter * 3, height: dropDiameter * 2)
         cloud.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(dropDiameter / 2))
         cloud.physicsBody?.pinned = true
         cloud.physicsBody?.isDynamic = true
         cloud.physicsBody?.restitution = 0.1
         cloud.physicsBody?.friction = 0.2
         cloud.physicsBody?.categoryBitMask = PhysicsCategory.defaultObject
         cloud.physicsBody?.collisionBitMask = PhysicsCategory.drop
         cloud.physicsBody?.contactTestBitMask = PhysicsCategory.drop
         
         addChild(cloud)
     }
     
     private func setFire(on position: CGPoint) {
         if let wildFire = SKEmitterNode(fileNamed: "wildFire") {
             wildFire.position = position
             wildFire.particleSize = CGSize(
                 width: Double(dropDiameter) * 2.7,
                 height: 100.0
             )
             wildFire.physicsBody = SKPhysicsBody(
                 rectangleOf: CGSize(
                     width: Double(dropDiameter) * 2.7,
                     height: 100.0
                 )
             )
             wildFire.physicsBody?.isDynamic = false
             wildFire.physicsBody?.categoryBitMask = PhysicsCategory.aim
             wildFire.physicsBody?.collisionBitMask = PhysicsCategory.none
             wildFire.physicsBody?.contactTestBitMask = PhysicsCategory.drop
             
             addChild(wildFire)
             
             wildFiersCounter += 1
         }
     }
     
     private func setSmoke(on position: CGPoint) {
         if let smoke = SKEmitterNode(fileNamed: "smoke") {
             smoke.position = position
             smoke.particleSize = CGSize(
                 width: 30 * 2.7,
                 height: 100.0
             )
             smoke.physicsBody = SKPhysicsBody(
                 rectangleOf: CGSize(
                     width: Double(dropDiameter) * 2.7,
                     height: 100.0
                 )
             )
             smoke.physicsBody?.isDynamic = false
             smoke.physicsBody?.categoryBitMask = PhysicsCategory.aim
             smoke.physicsBody?.collisionBitMask = PhysicsCategory.none
             smoke.physicsBody?.contactTestBitMask = PhysicsCategory.drop
             
             addChild(smoke)
             
             wildFiersCounter += 1
         }
     }
     
     private func setRain(on position: CGPoint) {
         if let rain = SKEmitterNode(fileNamed: "rain") {
             rain.position = position
             rain.particleSize = CGSize(width: dropDiameter, height: 30)
             addChild(rain)
             
             let removeAfterDead = SKAction.sequence(
                 [
                     SKAction.wait(forDuration: 3),
                     SKAction.removeFromParent()
                 ]
             )
             rain.run(removeAfterDead)
         }
     }
     
     private func setSteam(on position: CGPoint) {
         if let steam = SKEmitterNode(fileNamed: "boil") {
             steam.position = position
             steam.particleSize = CGSize(width: dropDiameter, height: dropDiameter)
             addChild(steam)
             
             let removeAfterDead = SKAction.sequence(
                 [
                     SKAction.wait(forDuration: 3),
                     SKAction.removeFromParent()
                 ]
             )
             steam.run(removeAfterDead)
         }
     }
     
     private func setAim(on position: CGPoint) {
         let aim = SKSpriteNode(
             color: .clear,
             size: CGSize(
                 width: dropDiameter * 4,
                 height: dropDiameter * 3
             )
         )
         aim.position = position
         aim.physicsBody = SKPhysicsBody(
             rectangleOf: CGSize(
                 width: dropDiameter * 4,
                 height: dropDiameter * 3
             )
         )
         aim.physicsBody?.pinned = true
         aim.physicsBody?.isDynamic = false
         
         aim.physicsBody?.categoryBitMask = PhysicsCategory.aim
         aim.physicsBody?.collisionBitMask = PhysicsCategory.none
         aim.physicsBody?.contactTestBitMask = PhysicsCategory.drop
         
         addChild(aim)
         
         wildFiersCounter += 1
     }
     
     
     
     private func setBoard() {
         let kMinD: CGFloat = 600 / 30
         let kMaxD: CGFloat = 700 / 100
         
         let k: CGFloat = kMinD - (kMinD - kMaxD) * ((dropDiameter - 30) / 30)
         print(k, dropDiameter * k)
         
         
         let minYPos =  -frame.height / 2 + 600
         let maxCloudsInRange = 4
         
         for range in stride(from: maxCloudsInRange, to: 1, by: -1) {
             
             let currentYPos = minYPos + CGFloat((maxCloudsInRange - range)) * dropDiameter * 3
             let rangeFrame = (CGFloat(range) - 1) / 2.0 * 4 * dropDiameter
             
             for i in stride(from: rangeFrame, to: -rangeFrame - 1, by: -4 * dropDiameter) {
                 
                 let cloudPosition = CGPoint(x: i, y: currentYPos)
                 setCloud(position: cloudPosition)
                 
                 if maxCloudsInRange - range == 1 {

                     let aimPosition = CGPoint(x: i, y: minYPos - 210)
                     setAim(on: aimPosition)
                     
                     let firePosition = CGPoint(x: i, y: minYPos - 240)
                     setFire(on: firePosition)
                     
                     setSmoke(on: aimPosition)
                     
                 }
             }
         }
         
         setFrame()
     }
     
     private func setFrame() {
         physicsBody = SKPhysicsBody(
             edgeLoopFrom: frame.inset(
                 by: UIEdgeInsets(
                     top: 330,
                     left: 1,
                     bottom: 50,
                     right: 1
                 )
             )
         )
     }
     
     private func setDrop() {
         drop?.removeFromParent()
         
         guard !dropIsActive else { return }
         
         drop = SKSpriteNode(imageNamed: "drop")
         guard let drop = drop else { return }
         drop.physicsBody = SKPhysicsBody(
             texture: SKTexture(imageNamed: "drop"),
             size: CGSize(
                 width: dropDiameter,
                 height: dropDiameter * 1.37
             )
         )
         drop.physicsBody?.affectedByGravity = true
         drop.physicsBody?.isDynamic = true
         drop.physicsBody?.mass = 1
         drop.physicsBody?.allowsRotation = true
         drop.physicsBody?.friction = 0.2
         drop.physicsBody?.restitution = 0.2
         drop.physicsBody?.categoryBitMask = PhysicsCategory.drop
         drop.physicsBody?.collisionBitMask = PhysicsCategory.defaultObject
         drop.physicsBody?.contactTestBitMask = PhysicsCategory.aim
         
         drop.position = CGPoint(
             x: Double.random(in: -50...50),
             y: frame.height / 2 - 120
         )
         drop.size = CGSize(
             width: dropDiameter,
             height: dropDiameter * 1.37
         )
         
         addChild(drop)
         
         dropIsActive = true
     }
     
     private func setPointsLabel(
         position: CGPoint,
         text: String,
         color: UIColor,
         size: CGFloat = 50
     ) {
         
         let label = SKLabelNode(fontNamed: "HelveticaNeue-Light")
         label.fontSize = size
         label.fontColor = color
         label.position = position
         label.zRotation = CGFloat.random(in: -45...45) * .pi / 180
         
         label.text = text
         label.zPosition = 1
         label.horizontalAlignmentMode = .left
         addChild(label)
         
         
         let moveUp = SKAction.moveBy(x: .random(in: -10...10), y: 100, duration: 0.5)
         let appear = SKAction.group(
             [
                 SKAction.scale(to: 1, duration: 0.25),
                 SKAction.fadeIn(withDuration: 0.25),
                 moveUp
             ]
         )
         
         let disappear = SKAction.group(
             [
                 SKAction.scale(to: 2, duration: 0.25),
                 SKAction.fadeOut(withDuration: 0.25),
             ]
         )
         
         let sequence = SKAction.sequence(
             [
                 appear,
                 SKAction.wait(forDuration: 0.2),
                 disappear,
                 SKAction.removeFromParent()
             ]
         )
         
         label.run(sequence)
     }
     
     @objc private func turbulenceFlowButtonTapped() {
         drop?.physicsBody!.applyImpulse(
             CGVector(
                 dx: Int.random(in: -10...10),
                 dy: 1000
             )
         )
         score -= 33
         setPointsLabel(
             position: CGPoint(
                 x: frame.width / 2 - 200,
                 y: 300 - frame.height / 2
             ),
             text: "-33",
             color: .red
         )
     }
     
     @objc private func refreshDrop() {
         score -= 50
         
         setPointsLabel(
             position: CGPoint(
                 x: -frame.width / 2 + 200,
                 y: 300 - frame.height / 2
             ),
             text: "-50",
             color: .red
         )
         dropIsActive = false
         setDrop()
     }
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         
     }
     
     deinit {
         NotificationCenter.default.removeObserver(self)
     }
     
 }

 extension BaseLevelScene: SKPhysicsContactDelegate {
     
     func didBegin(_ contact: SKPhysicsContact) {
         
         let bodyA = contact.bodyA
         let bodyB = contact.bodyB
         
         if bodyA.categoryBitMask == PhysicsCategory.drop &&
             bodyB.categoryBitMask == PhysicsCategory.aim ||
             bodyB.categoryBitMask == PhysicsCategory.drop &&
             bodyA.categoryBitMask == PhysicsCategory.aim
         {
             
             if dropIsActive { dropIsActive.toggle()
                 bodyA.node?.removeFromParent()
                 bodyB.node?.removeFromParent()
                 
                 setSteam(on: contact.contactPoint)
                 
                 score += 100
                 
                 setPointsLabel(
                     position: contact.contactPoint,
                     text: "+100",
                     color: .green
                 )
                 
                 AudioServicesPlayAlertSoundWithCompletion(
                     SystemSoundID(
                         kSystemSoundID_Vibrate
                     ), {}
                 )
                 
                 let wait = SKAction.wait(forDuration: 1)
                 let go = SKAction.run { [weak self] in
                     self?.setDrop()
                 }
                 wildFiersCounter -= 1
                 run(SKAction.sequence([wait, go]))
                 
             }
             
         }
         
         if bodyA.categoryBitMask == PhysicsCategory.drop &&
             bodyB.categoryBitMask == PhysicsCategory.defaultObject
         {
             
             bodyB.node?.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
             
             let position = bodyB.node?.position ?? contact.contactPoint
             setRain(on: position)
             score += 1
             
             UISelectionFeedbackGenerator().selectionChanged()
  
         } else if bodyB.categoryBitMask == PhysicsCategory.drop &&
                     bodyA.categoryBitMask == PhysicsCategory.defaultObject
         {
             bodyA.node?.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
             
             let position = contact.contactPoint
             
             setRain(on: position)
             score += 1
             UISelectionFeedbackGenerator().selectionChanged()
         }
         
     }
 }

 
 
 
 
 */

//    private func setLabel(
//        _ label: SKLabelNode,
//        with text: String,
//        to position: CGPoint
//    ) {
//        label.fontSize = 50
//        label.fontColor = .white
//        label.position = position
//
//        label.text = text
//        label.zPosition = 1
//        label.horizontalAlignmentMode = .left
//        addChild(label)
//    }


//    override func update(_ currentTime: TimeInterval) {
//        // Called before each frame is rendered


//        let path = CGMutablePath()
//        path.addArc(center: CGPoint.zero,
//                    radius: 15,
//                    startAngle: 0,
//                    endAngle: CGFloat.pi * 2,
//                    clockwise: true)
//        let ball = SKShapeNode(path: path)
//        ball.lineWidth = 0.5
//        ball.fillColor = .blue
//        ball.strokeColor = .black
//        ball.glowWidth = 0.2
//
//        ball.position = CGPoint(x: 0, y: 800)
//
//        ball.physicsBody = SKPhysicsBody(circleOfRadius: 15)
//        ball.physicsBody?.isDynamic = true
//        ball.physicsBody?.affectedByGravity = true
//        ball.physicsBody?.mass = 1
//
//        spinnyNode = ball
//        self.addChild(spinnyNode)


//        let moveBackground = SKAction.move(by: CGVector(dx: -20000, dy: 0) , duration: 100)

//        backgroundNode.run(moveBackground)

//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
//    }
//
//
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
//
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
//    }
