//
//  GameViewController.swift
//  Game
//
//  Created by vitasiy on 21.10.2021.
//


import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var evaLabel: UILabel!
    @IBOutlet weak var tfLabel: UILabel!
    
    private let uD = StorageManager.shared
    private let levelManager = LevelManager.shared
    
    private var userInfo = UserDataInfo()
//    private var level = 6
    private var evaCount = 0
    private var tFCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uD.save(userInfo)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameOver),
            name: Notification.Name("levelCompleted"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setLabels),
            name: Notification.Name("scoreHaschanged"),
            object: nil
        )
        
        scoreLabel.text = "SCORE: \(userInfo.score)"
        levelLabel.text = "LEVEL: \(userInfo.level)"
        evaLabel.text = "Evaporations: \(userInfo.evaCounter)"
        tfLabel.text = "Turbulence Flows: \(userInfo.tFCounter)"
        
        setLevelView(for: userInfo.level)
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        userInfo = uD.fatchStatistics()
//        
//        scoreLabel.text = "SCORE: \(userInfo.score)"
//        levelLabel.text = "LEVEL: \(userInfo.level)"
//        evaLabel.text = "Evaporations: \(userInfo.evaCounter)"
//        tfLabel.text = "Turbulence Flows: \(userInfo.tFCounter)"
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        uD.save(userInfo)
        
    }
    
    private func setLevelView(for level: Int) {
        
        if let view = self.view as! SKView? {
            
            let sceneName: String
            let dropDiameter: CGFloat
            let maxCloudsInRange: Int
            let minCloudsInRange: Int
            
            switch level {
                
            case 1:
                sceneName = "Level1Scene"
                dropDiameter = 60
                maxCloudsInRange = 5
                minCloudsInRange = 2
            case 2:
                sceneName = "Level2Scene"
                dropDiameter = 50
                maxCloudsInRange = 6
                minCloudsInRange = 2
            case 3:
                sceneName = "Level3Scene"
                dropDiameter = 40
                maxCloudsInRange = 7
                minCloudsInRange = 2
            case 4:
                sceneName = "Level4Scene"
                dropDiameter = 30
                maxCloudsInRange = 8
                minCloudsInRange = 3
            case 5:
                sceneName = "Level5Scene"
                dropDiameter = 30
                maxCloudsInRange = 9
                minCloudsInRange = 2
            case 6:
                sceneName = "Level6Scene"
                dropDiameter = 30
                maxCloudsInRange = 10
                minCloudsInRange = 2
            case 7:
                sceneName = "Level7Scene"
                dropDiameter = 25
                maxCloudsInRange = 11
                minCloudsInRange = 3
            case 8:
                sceneName = "Level8Scene"
                dropDiameter = 25
                maxCloudsInRange = 12
                minCloudsInRange = 2
            case 9:
                sceneName = "Level9Scene"
                dropDiameter = 22
                maxCloudsInRange = 14
                minCloudsInRange = 5
                
            default:
                sceneName = "BaseLevelScene"
                dropDiameter = 80
                maxCloudsInRange = 4
                minCloudsInRange = 2
                
            }
            
            levelManager.loadLevel(
                sceneName: sceneName,
                into: view,
                with: dropDiameter,
                maxCloudsInRange: maxCloudsInRange,
                minCloudsInRange: minCloudsInRange,
                score: userInfo.score,
                level: userInfo.level
            )
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    @objc private func gameOver(_ notification: Notification) {
        
        setLabels(notification)
        
        let alert = UIAlertController(
            title: "LEVEL COMPETED",
            message: "Your Score: \(userInfo.score)",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "NEXT LEVEL",
            style: .default
        ) { [weak self] _ in
            // segue to the next lvl VC with gravity
            //            self?.dismiss(animated: true)
            
            guard let strongSelf = self
            else { return }
            strongSelf.userInfo.level += 1
            strongSelf.uD.save(strongSelf.userInfo)

            strongSelf.setLevelView(for: strongSelf.userInfo.level)
            
//            if let view = strongSelf.view as! SKView? {
//                if let scene = SKScene(fileNamed: "GameScene") {
//                    scene.scaleMode = .aspectFit
//                    view.presentScene(scene)
//                }
//                view.ignoresSiblingOrder = true
//                view.showsFPS = false
//                view.showsNodeCount = false
//                
//            }
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc private func setLabels(_ notification: Notification) {
        
        let score = notification.userInfo?["score"] as! Int
        let level = notification.userInfo?["level"] as! Int
        
        userInfo.score <= score ?
        scoreLabel.animatePulseAndColorChange(.green) :
        scoreLabel.animatePulseAndColorChange(.red)
        
        userInfo.score = score
        userInfo.level = level
        
        if userInfo.score > userInfo.bestScore {
            userInfo.bestScore = userInfo.score
        }
        
        userInfo.evaCounter = evaCount
        userInfo.tFCounter = tFCount
        
        uD.save(userInfo)
        
        scoreLabel.text = "SCORE: \(userInfo.score)"
        levelLabel.text = "LEVEL: \(userInfo.level)"
        evaLabel.text = "Evaporations: \(userInfo.evaCounter)"
        tfLabel.text = "Turbulence Flows: \(userInfo.tFCounter)"
        
        
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func turbulenceFlowButtonPressed(_ sender: Any) {
        tFCount += 1
        NotificationCenter.default.post(
            name: Notification.Name("turbulenceFlowButtonTapped"),
            object: nil
        )
    }
    
    
    @IBAction func evaporationButtonTapped(_ sender: Any) {
        evaCount += 1
        NotificationCenter.default.post(
            name: Notification.Name("evaporationButtonTapped"),
            object: nil
        )
    }
    
}
