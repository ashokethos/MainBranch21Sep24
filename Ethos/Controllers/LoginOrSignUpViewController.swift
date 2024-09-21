//
//  LoginOrSignUpViewController.swift
//  Ethos
//
//  Created by mac on 28/07/23.
//

import UIKit
import AVFoundation
import Mixpanel

class LoginOrSignUpViewController: UIViewController {
    
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnPauseplay: UIButton!
    
    var layer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startPlayer()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        self.btnSkip.isHidden = !(Userpreference.shouldShowSkip ?? true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.layer.player?.pause()
        self.btnPauseplay.isSelected = false
        self.layer.player = nil
        self.layer.removeFromSuperlayer()
    }
    
    func setup() {
        self.lblTitle.isHidden = true
        self.lblMessage.isHidden = true
        btnSignIn.setBorder(borderWidth: 1, borderColor: .white, radius: 0)
        btnSignUp.setBorder(borderWidth: 1, borderColor: .white, radius: 0)
        
        lblTitle.setAttributedTitleWithProperties(title: "Where watch enthusiast\ncome together",
        font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
        alignment: .center,
        foregroundColor: .white,
        lineHeightMultiple: 1.04,
        kern: 0.1
        )
        
        lblMessage.setAttributedTitleWithProperties(title: "Unravelling the finest moments,\nexclusively yours!",
        font: EthosFont.Brother1816Regular(size: 12),
        alignment: .center, foregroundColor: .white,
        kern: 0.1
        )
        
        btnSignIn.setAttributedTitleWithProperties(
            title: "Sign in".uppercased(),
            font: EthosFont.Brother1816Bold(size: 10),
            alignment: .center,
            foregroundColor: .white,
            kern: 0.5
        )
        
        btnSignUp.setAttributedTitleWithProperties(
            title: "Sign up".uppercased(),
            font: EthosFont.Brother1816Bold(size: 10),
            alignment: .center,
            foregroundColor: .black,
            kern: 0.5
        )
        
        btnSkip.setAttributedTitleWithProperties(
            title: "SKIP",
            font: EthosFont.Brother1816Medium(size: 10),
            alignment: .center,
            foregroundColor: .white,
            kern: 5
        )
    }
    
    func startPlayer() {
        if let url = Bundle.main.url(forResource: "SplashMain", withExtension:"mp4") {
            let player = AVPlayer(url: url)
            layer.player = player
            layer.videoGravity = .resizeAspectFill
            layer.frame = self.imageView.frame
            self.imageView.layer.addSublayer(layer)
            layer.player?.play()
            self.btnPauseplay.isSelected = true
            addObseverToPlayer()
        }
    }
    
    func addObseverToPlayer() {
        self.layer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale:CMTimeScale(NSEC_PER_SEC)), queue:DispatchQueue.main) { time in
            let duration = CMTimeGetSeconds( self.layer.player?.currentItem?.duration ?? CMTime())
            let progress = Float((CMTimeGetSeconds(time) / duration))
            if progress == 1 {
                self.layer.player?.pause()
                self.layer.player?.seek(to: CMTime.init(seconds: 2, preferredTimescale: .max) )
                self.btnPauseplay.isSelected = false
            }
        }
    }
    
    @IBAction func btnPausePlayDidTapped(_ sender: UIButton) {
        btnPauseplay.isSelected = !btnPauseplay.isSelected
        if btnPauseplay.isSelected {
            self.layer.player?.play()
        } else {
            self.layer.player?.pause()
        }
    }
    
    @IBAction func btnSignInDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: LoginWithMobileViewController.self)) as? LoginWithMobileViewController {
            Mixpanel.mainInstance().trackWithLogs(event: "Sign In Clicked", properties: [EthosConstants.Platform : EthosConstants.IOS, EthosConstants.Registered : EthosConstants.N])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSignUpDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SignUpViewController.self)) as? SignUpViewController {
            Mixpanel.mainInstance().trackWithLogs(event: "Sign Up Clicked", properties: [EthosConstants.Platform : EthosConstants.IOS, EthosConstants.Registered : EthosConstants.N])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSkipDidTapped(_ sender: UIButton) {
        Mixpanel.mainInstance().trackWithLogs(event: "User Registration Skipped", properties: [EthosConstants.Email :"", EthosConstants.UID : "", EthosConstants.Gender : "", EthosConstants.Registered : EthosConstants.N, EthosConstants.Platform : EthosConstants.IOS])
        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
            UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }?.rootViewController = vc
        }
    }
}
