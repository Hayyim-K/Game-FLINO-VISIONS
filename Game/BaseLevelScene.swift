//
//  BaseLevelScene.swift
//  Game
//
//  Created by Hayyim on 18/09/2024.
//


import AudioToolbox
import SpriteKit
//import GameplayKit

class BaseLevelScene: SKScene {
    
    var maxCloudsInRange = 4
    var minCloudsInRange = 2
    
    var dropDiameter: CGFloat = 80
    
    var score = 0 {
        willSet {
            NotificationCenter.default.post(
                name: Notification.Name("scoreHaschanged"),
                object: nil,
                userInfo: ["score": score, "level": level]
            )
        }
    }
    
    var level = 0
    
    var evaPrice = 50
    var tFPrice = 33
    
    var deviationByX: Int = 10
    var deviationByY: Int = 1000
    
    var bgColor: UIColor = #colorLiteral(red: 0.702839592, green: 0.1938713611, blue: 0.9012210876, alpha: 0.55)
    
    private var drop: SKSpriteNode?
    
    private var dropIsActive = false
    
    private var clouds = ["cloud-1", "cloud-2", "cloud-4", "cloud-5"]
    private var stormClouds = ["cloud-11", "cloud-22", "cloud-44", "cloud-55"]
    
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
    
    func setBackGround() {
        let background = SKSpriteNode(
            color: bgColor,
            size: CGSize(width: frame.width, height: frame.height)
        )
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -100
        addChild(background)
    }
    
    func setCloud(position: CGPoint, isStorm: Bool = false) {
        
        let cloudType = !isStorm ?
        clouds.randomElement()! :
        stormClouds.randomElement()!
        
        let cloud = SKSpriteNode(imageNamed: cloudType)
        cloud.position = position
        cloud.size = CGSize(
            width: dropDiameter * 3,
            height: dropDiameter * 2
        )
        cloud.physicsBody = SKPhysicsBody(
            circleOfRadius: CGFloat(dropDiameter / 2)
        )
        cloud.physicsBody?.pinned = true
        cloud.physicsBody?.isDynamic = !isStorm ? true : false
        cloud.physicsBody?.restitution = !isStorm ? 0.1 : -0.5
        cloud.physicsBody?.friction = !isStorm ? 0.2 : 0.5
        cloud.physicsBody?.categoryBitMask = PhysicsCategory.defaultObject
        cloud.physicsBody?.collisionBitMask = PhysicsCategory.drop
        cloud.physicsBody?.contactTestBitMask = PhysicsCategory.drop
        
        addChild(cloud)
    }
    
    func setFire(on position: CGPoint) {
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
    
    func setSmoke(on position: CGPoint) {
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
    
    func setRain(on position: CGPoint) {
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
    
    func setSteam(on position: CGPoint) {
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
    
    func setAim(on position: CGPoint) {
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
    
    
    
    func setBoard() {
        
        let minYPos =  -frame.height / 2 + 600
        
        for range in stride(from: maxCloudsInRange, to: minCloudsInRange - 1, by: -1) {
            
            let currentYPos = minYPos + CGFloat((maxCloudsInRange - range)) * dropDiameter * 3
            let rangeFrame = (CGFloat(range) - 1) / 2.0 * 4 * dropDiameter
            
            for i in stride(from: rangeFrame, to: -rangeFrame - 1, by: -4 * dropDiameter) {
                
                let cloudPosition = CGPoint(x: i, y: currentYPos)
                setCloud(position: cloudPosition, isStorm: Bool.random())
                
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
    
    func setFrame() {
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
    
    func setDrop() {
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
            x: Double.random(in: -dropDiameter * 2...dropDiameter * 2),
            y: frame.height / 2 - 120
        )
        drop.size = CGSize(
            width: dropDiameter,
            height: dropDiameter * 1.37
        )
        
        addChild(drop)
        
        dropIsActive = true
    }
    
    func setPointsLabel(
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
    
    @objc func turbulenceFlowButtonTapped() {
        drop?.physicsBody!.applyImpulse(
            CGVector(
                dx: Int.random(in: -deviationByX...deviationByX),
                dy: deviationByY
            )
        )
        score -= tFPrice
        setPointsLabel(
            position: CGPoint(
                x: frame.width / 2 - 200,
                y: 300 - frame.height / 2
            ),
            text: "-\(tFPrice)",
            color: .red
        )
    }
    
    @objc func refreshDrop() {
        score -= evaPrice
        
        setPointsLabel(
            position: CGPoint(
                x: -frame.width / 2 + 200,
                y: 300 - frame.height / 2
            ),
            text: "-\(evaPrice)",
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
