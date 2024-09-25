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
    
    @IBOutlet var tFLabels: [UILabel]!
    
    @IBOutlet weak var skView: SKView!
    
    @IBOutlet weak var gravityDirectionImage: UIImageView!
    
    private let uD = StorageManager.shared
    private let levelManager = LevelManager.shared
    
    private var userInfo = UserDataInfo()
    
    private var evaCount = 0
    private var tFCount = 0
    
    private var gravitationDirection: GravitationDirections = .down
    
    private var savedScore = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView.backgroundColor = .clear
        
//        if let backGroundImage = UIImage(named: "backGround") {
//            let backGround = UIImageView(image: backGroundImage)
//            backGround.contentMode = .scaleAspectFill
//            
//            view.addSubview(backGround)
//            view.sendSubviewToBack(backGround)
//            
//        }
        
        userInfo.bestScore = uD.fatchStatistics().bestScore
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configureGravityDirectionImage),
            name: Notification.Name("gravityDirectionHasChanged"),
            object: nil
        )
        
        scoreLabel.textColor = .black
        scoreLabel.text = "SCORE: \(userInfo.score)"
        levelLabel.text = "LEVEL: \(userInfo.level)"
        evaLabel.text = "EVA: \(userInfo.evaCounter)"
        tFLabels.forEach{ $0.text = "TF: \(userInfo.tFCounter)" }
        
        setLevelView(for: userInfo.level)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        uD.save(userInfo)
    }
    
    private func setLevelView(for level: Int) {
        
        let sceneName: String
        
        var isGravityDiviation = false
        var isFixedGravity = true
        var xGravity: Double = 10
        var yGravity: Double = 10
        var wildFireRestoreInterval: Double = 30
        
        var maxCloudsInRange = 4
        var minCloudsInRange = 2
        var dropDiameter: CGFloat = 80
        var evaPrice = 50
        var tFPrice = 15
        var deviationByX: Int = 1000
        var bgColor: UIColor = #colorLiteral(red: 0.702839592, green: 0.1938713611, blue: 0.9012210876, alpha: 0.55)
        
        var cloudCollisionPrice = 1
        var stormCloudCollisionPrice = 2
        
        var deviationByY: Int = 1000
        
        
        switch level {
            
        case 1:
            sceneName = "Level1Scene"
            
            maxCloudsInRange = 5
            minCloudsInRange = 2
            wildFireRestoreInterval = 50
            dropDiameter = 60
            tFPrice = 17
            
            deviationByX = 900
            
            bgColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
            
            
        case 2:
            sceneName = "Level2Scene"
            dropDiameter = 50
            maxCloudsInRange = 6
            minCloudsInRange = 2
            bgColor = #colorLiteral(red: 0.3568137853, green: 0.8410677813, blue: 0.9012210876, alpha: 0.55)
            tFPrice = 22
            evaPrice = 55
            
            deviationByX = 300
            let range = [5000, 10000, 3000, 100, 500, 1000, 1000, 100]
            deviationByY = range.randomElement()! * [-1, 1].randomElement()!
            
            cloudCollisionPrice = 1
            stormCloudCollisionPrice = 3
            
            wildFireRestoreInterval = 60
            
            
        case 3:
            sceneName = "Level3Scene"
            dropDiameter = 40
            maxCloudsInRange = 7
            minCloudsInRange = 2
            bgColor = #colorLiteral(red: 0.5464277018, green: 0.6973573371, blue: 0.9012210876, alpha: 0.55)
            tFPrice = 30
            evaPrice = 60
            
            deviationByX = 500
            
            cloudCollisionPrice = 1
            stormCloudCollisionPrice = 3
            
            isGravityDiviation = true
            isFixedGravity = false
            xGravity = 10
            yGravity = 10
            
            
            wildFireRestoreInterval = 10
            
        case 4:
            sceneName = "Level4Scene"
            dropDiameter = 30
            maxCloudsInRange = 8
            minCloudsInRange = 3
            bgColor = #colorLiteral(red: 0.9012210876, green: 0.6507516332, blue: 0.6547421639, alpha: 0.55)
            evaPrice = 65
            tFPrice = 15
            
            deviationByX = 200
            
            cloudCollisionPrice = 2
            stormCloudCollisionPrice = 4
            
            isGravityDiviation = true
            isFixedGravity = true
            xGravity = 0
            yGravity = -10
            
            
            wildFireRestoreInterval = 60
            
        case 5:
            sceneName = "Level5Scene"
            dropDiameter = 30
            maxCloudsInRange = 9
            minCloudsInRange = 2
            bgColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0.03921568627, alpha: 0.8114243659)
            evaPrice = 70
            tFPrice = 50
            
            deviationByX = 100
            
            cloudCollisionPrice = 2
            stormCloudCollisionPrice = 5
            
            wildFireRestoreInterval = 100
            
        case 6:
            sceneName = "Level6Scene"
            dropDiameter = 30
            maxCloudsInRange = 10
            minCloudsInRange = 2
            bgColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
            evaPrice = 100
            tFPrice = 300
            
            deviationByX = 100
            
            cloudCollisionPrice = 3
            stormCloudCollisionPrice = 100
            
            isGravityDiviation = true
            isFixedGravity = false
            xGravity = 10
            yGravity = 10
            
            
            wildFireRestoreInterval = 20
            
        case 7:
            sceneName = "Level7Scene"
            dropDiameter = 25
            maxCloudsInRange = 11
            minCloudsInRange = 3
            bgColor = #colorLiteral(red: 0, green: 0.6140567681, blue: 0.9469888041, alpha: 0.55)
            evaPrice = 250
            tFPrice = 20
            
            deviationByX = 90
            
            cloudCollisionPrice = 10
            stormCloudCollisionPrice = 50
            
            isGravityDiviation = true
            isFixedGravity = true
            xGravity = 0
            yGravity = 8
            
            wildFireRestoreInterval = 160
            
            
        case 8:
            sceneName = "Level8Scene"
            dropDiameter = 25
            maxCloudsInRange = 12
            minCloudsInRange = 2
            bgColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 0.8796610809)
            evaPrice = 80
            tFPrice = 70
            
            deviationByX = 100
            
            cloudCollisionPrice = 20
            stormCloudCollisionPrice = 50
            
            wildFireRestoreInterval = 120
            
        case 9:
            sceneName = "Level9Scene"
            dropDiameter = 22
            maxCloudsInRange = 14
            minCloudsInRange = 5
            bgColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            evaPrice = 50
            tFPrice = 5
            
            deviationByX = 100
            
            cloudCollisionPrice = 90
            stormCloudCollisionPrice = 100
            
            wildFireRestoreInterval = 10
            
        default:
            sceneName = "BaseLevelScene"
            dropDiameter = 80
            maxCloudsInRange = 4
            minCloudsInRange = 2
            
            isGravityDiviation = false
            isFixedGravity = true
            xGravity = 10
            yGravity = 10
            
            evaPrice = 50
            tFPrice = 15
            cloudCollisionPrice = 1
            stormCloudCollisionPrice = 2
            deviationByX = 1000
            deviationByY = 1000
            bgColor = #colorLiteral(red: 0.702839592, green: 0.1938713611, blue: 0.9012210876, alpha: 0.55)
            
            wildFireRestoreInterval = 40
            
        }
        
        levelManager.loadLevel(
            sceneName: sceneName,
            into: skView,
            with: dropDiameter,
            isGravityDiviation: isGravityDiviation,
            isFixedGravity: isFixedGravity,
            xGravity: xGravity,
            yGravity: yGravity,
            wildFireRestoreInterval: wildFireRestoreInterval,
            maxCloudsInRange: maxCloudsInRange,
            minCloudsInRange: minCloudsInRange,
            score: userInfo.score,
            level: userInfo.level,
            evaPrice: evaPrice,
            tFPrice: tFPrice,
            cloudCollisionPrice: cloudCollisionPrice,
            stormCloudCollisionPrice: stormCloudCollisionPrice,
            deviationByX: deviationByX,
            deviationByY: deviationByY,
            bgColor: bgColor
        )
        
        gravityDirectionImage.isHidden = !isGravityDiviation
        
        savedScore = userInfo.score
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.backgroundColor = .clear
    }
    
    @objc private func configureGravityDirectionImage(_ notification: Notification) {
        let (x, y) = (
            notification.userInfo?["x"] as! Double,
            notification.userInfo?["y"] as! Double
        )
        
        switch (x, y) {
        case (0.1..., -1...1):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.right.rawValue
            )
        case (-1...1, 0.1...):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.up.rawValue
            )
        case (0.01..., 0.01...):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.upRight.rawValue
            )
        case (...0, ...0):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.downLeft.rawValue
            )
        case (...0, -1...1):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.left.rawValue
            )
        case (-1...1, ...0):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.down.rawValue
            )
        case (...0, 0.01...):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.upLeft.rawValue
            )
        case (0.01..., ...0):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.downRight.rawValue
            )
        default:
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.down.rawValue
            )
        }
        
    }
    
    @objc private func gameOver(_ notification: Notification) {
        
        setLabels(notification)
        
        let alert = userInfo.score > 0 ?
        UIAlertController(
            title: userInfo.level < 9 ? "LEVEL COMPETED" : "GAME OVER",
            message: "Your Score: \(userInfo.level < 9 ? userInfo.score + 1 : userInfo.score)",
//            message: "Your Score: \(userInfo.level < 9 ? userInfo.score + 101 : userInfo.score + 1)",
            preferredStyle: .alert
        ) :
        UIAlertController(
            title: "LEVEL NOT COMPETED",
            message: "Your Score Is Below Zero!",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: userInfo.score > 0 ?
            (userInfo.level < 9 ? "NEXT LEVEL" : "END THE GAME") :
                "TRY AGAIN",
            style: .default
        ) { [weak self] _ in
            
            
            guard let strongSelf = self
            else { return }
            
            strongSelf.userInfo.level += strongSelf.userInfo.score > 0 ? 1 : 0
            
            if strongSelf.userInfo.score < 0 { strongSelf.userInfo.score = strongSelf.savedScore }
            
            strongSelf.uD.save(strongSelf.userInfo)
            
            strongSelf.userInfo.level <= 9 ?
            strongSelf.setLevelView(for: strongSelf.userInfo.level) :
            strongSelf.dismiss(animated: true)
            
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc private func setLabels(_ notification: Notification) {
        
        let score = notification.userInfo?["score"] as! Int
        let level = notification.userInfo?["level"] as! Int
        
        //        scoreLabel.textColor = .black
        
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
        evaLabel.text = "EVA: \(userInfo.evaCounter)"
        tFLabels.forEach{ $0.text = "TF: \(userInfo.tFCounter)" }
        
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
    
    
    @IBAction func turbulenceFlowButtonPressed(_ sender: UIButton) {
        tFCount += 1
        NotificationCenter.default.post(
            name: Notification.Name("turbulenceFlowButtonTapped"),
            object: nil,
            userInfo: ["tag": sender.tag]
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
