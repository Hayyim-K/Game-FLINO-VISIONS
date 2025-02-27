//
//  GameScene.swift
//  Game
//
//  Created by vitasiy on 21.10.2021.
//


import AudioToolbox
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var drop: SKSpriteNode?
    
    private var dropIsActive = false
    
    private var clouds = ["cloud-1", "cloud-2", "cloud-4", "cloud-5"]
    
    private let uD = StorageManager.shared
    
    private var userInfo = UserDataInfo()
    
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
                NotificationCenter.default.post(
                    name: Notification.Name("levelCompleted"),
                    object: nil,
                    userInfo: ["score": score, "level": level]
                )
            }
        }
    }

    
    override func didMove(to view: SKView) {
        
        userInfo = uD.fatchStatistics()
        score += 1
        score = userInfo.score
        level = userInfo.level
        
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
    
    private func setCloud(position: CGPoint, diameter: Int) {
        let cloudType = clouds.randomElement()!
        let cloud = SKSpriteNode(imageNamed: cloudType)
        cloud.position = position
        
        //                cloud.name = cloudType
        cloud.size = CGSize(width: diameter * 2, height: diameter * 2)
        cloud.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(diameter / 2))
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
            wildFire.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 100))
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
            smoke.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 100))
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
            rain.particleSize = CGSize(width: 30, height: 30)
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
            steam.particleSize = CGSize(width: 30, height: 30)
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
            size: CGSize(width: 120, height: 90)
        )
        aim.position = position
        aim.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 120, height: 90))
        aim.physicsBody?.pinned = true
        aim.physicsBody?.isDynamic = false
        
        aim.physicsBody?.categoryBitMask = PhysicsCategory.aim
        aim.physicsBody?.collisionBitMask = PhysicsCategory.none
        aim.physicsBody?.contactTestBitMask = PhysicsCategory.drop
        
        addChild(aim)
        
        wildFiersCounter += 1
    }
    
    
    
    private func setBoard() {
        
        let minYPos = -frame.height / 2 + 600
        let maxCloudsInRange = 10
        let ballDiameter = 30
        
        for range in stride(from: maxCloudsInRange, to: 2, by: -1) {
            
            let currentYPos = CGFloat((maxCloudsInRange - range) * 3 * ballDiameter) + minYPos
            let rangeFrame = (Float(range) - 1) / 2.0 * 4 * Float(ballDiameter)
            
            for i in stride(from: rangeFrame, to: -rangeFrame - 1, by: Float(-4 * ballDiameter)) {
                
                let cloudPosition = CGPoint(x: CGFloat(i), y: currentYPos)
                setCloud(position: cloudPosition, diameter: ballDiameter)
                
                if maxCloudsInRange - range == 1 {
                    
                    
                    
                    let aimPosition = CGPoint(x: CGFloat(i), y: minYPos - 100)
                    setAim(on: aimPosition)
                    
                    let firePosition = CGPoint(x: CGFloat(i), y: minYPos - 130)
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
                    top: 460,
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
            size: CGSize(width: 30, height: 41)
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
        drop.size = CGSize(width: 30, height: 41)
        
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
                SKAction.wait(forDuration: 0.25),
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

extension GameScene: SKPhysicsContactDelegate {
    
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
