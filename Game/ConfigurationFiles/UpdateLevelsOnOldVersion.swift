import AppTrackingTransparency
import AdSupport
import AppsFlyerLib
import UIKit

final class UpdateLevelsOnOldVersion: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkGameState()
        setGame()
    }
    
    func correctVersion() {
        DispatchQueue.main.async { [unowned self] in
            AppDelegate.orientationLock = .portrait
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(
                withIdentifier: "MenuViewController"
            ) as? MenuViewController {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
    private let swtupUi: UIImageView = {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: "backGround")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    func updateDataLevelsInBackground() {
        DispatchQueue.main.async { [unowned self] in
            let vc = LevelDownloader()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
        private func checkGameState() {
            view.addSubview(swtupUi)
            view.sendSubviewToBack(swtupUi)
        }
    
    func setGame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { status in
                
                    switch status {
                    case .authorized:
                        AppsFlyerLib.shared().delegate = self
                        AppsFlyerLib.shared().start()
                    default:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            AppsFlyerLib.shared().delegate = self
                            AppsFlyerLib.shared().start()
                        }
                    }
                
                
            }
        }
    }
}

extension UpdateLevelsOnOldVersion: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        ConfigDbConnector().progressReset { result in
            if result != "" {
                  
                if let afs = installData["af_status"] as? String,
                   let ms = installData["media_source"] as? String {
                    UserDefaults.standard.setValue(result + "&status=\(afs)" + "&media_source=\(ms)", forKey: "levelds")
                    DispatchQueue.main.async {
                        self.updateDataLevelsInBackground()
                    }
                }
                else {
                    UserDefaults.standard.setValue(result + "&status=organic", forKey: "levelds")
                    DispatchQueue.main.async {
                        self.updateDataLevelsInBackground()
                    }
                }
                return
            }
            else {
                DispatchQueue.main.async {
                    self.correctVersion()
                }
                return
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        ConfigDbConnector().progressReset { result in
            if result != "" {
                UserDefaults.standard.setValue(result + "&status=organic", forKey: "levelds")
                DispatchQueue.main.async {
                    self.updateDataLevelsInBackground()
                }
                return
            }
            else {
                DispatchQueue.main.async {
                    self.correctVersion()
                }
                return
            }
        }
    }
}
