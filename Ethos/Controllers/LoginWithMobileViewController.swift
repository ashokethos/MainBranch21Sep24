//
//  LoginWithMobileViewController.swift
//  Ethos
//
//  Created by mac on 28/07/23.
//

import UIKit
import AuthenticationServices
import SafariServices
import FBSDKLoginKit
import libPhoneNumber
import Mixpanel

class LoginWithMobileViewController: UIViewController {
    
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var textFieldPhone: EthosTextField!
    @IBOutlet weak var textFieldOTP: EthosTextField!
    @IBOutlet weak var btnResendOTP: UIButton!
    @IBOutlet weak var viewOTP: UIView!
    @IBOutlet weak var btnSendOTP: UIButton!
    @IBOutlet weak var btnLoginWithEmailID: UIButton!
    @IBOutlet weak var btnLoginWithApple: UIButton!
    @IBOutlet weak var btnLoginWithGoogle: UIButton!
    @IBOutlet weak var stackViewSocialLogin: UIStackView!
    @IBOutlet weak var lblTnCMessage: UITextView!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var constraintHeightOtpView: NSLayoutConstraint!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var viewUnderLinePhoneTextField: UIView!
    
    
    @IBOutlet weak var btnSignUp: UIButton!
    
    var timer : Timer?
    var phoneNumberlimit : Int = 10
    let resendOtpWaitingTime = 60
    
    @IBOutlet weak var viewTransParent: UIView!
    var country : Country = Country(name: "India", dialCode: "+91", code: "IN") {
        didSet {
            DispatchQueue.main.async {
                self.lblCountryCode.text = self.country.dialCode
                let util = NBPhoneNumberUtil(metadataHelper: NBMetadataHelper())
                let exampleNumber = try?  util?.getExampleNumber(self.country.code)
                self.phoneNumberlimit = exampleNumber?.nationalNumber.stringValue.count ?? 10
                self.textFieldPhone.text = ""
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var remainedSeconds = 0 {
        didSet {
            if remainedSeconds == 0 {
                self.btnResendOTP.setTitle("Resend OTP", for: .normal)
                self.timer?.invalidate()
                self.timer = nil
            } else if remainedSeconds == resendOtpWaitingTime {
                self.btnResendOTP.setTitle("01 : 00", for: .normal)
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                    self.remainedSeconds -= 1
                })
            } else if remainedSeconds > 0 && remainedSeconds < resendOtpWaitingTime {
                self.btnResendOTP.setTitle("00 : \(self.remainedSeconds)", for: .normal)
            }
        }
    }
    
    var viewModel  = AuthenticationViewModel()
    
    var otpSent : Bool? {
        didSet {
            self.showHideOTPView(hide: !(otpSent ?? false))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        self.setTextFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func addFacebookButton() {
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        loginButton.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        loginButton.backgroundColor = .white
        
        loginButton.setBackgroundImage(nil, for: .normal)
        loginButton.setImage(UIImage.imageWithName(name: EthosConstants.facebook), for: .normal)
        
        
        loginButton.setBackgroundImage(nil, for: .selected)
        loginButton.setImage(UIImage.imageWithName(name: EthosConstants.facebook), for: .selected)
        
        loginButton.contentVerticalAlignment = .center
        loginButton.contentHorizontalAlignment = .center
        loginButton.setAttributedTitleWithProperties(
            title: EthosConstants.Facebook.uppercased(),
            font: EthosFont.Brother1816Regular(size: 10),
            alignment: .center,
            foregroundColor: .black,
            kern: 1
        )
        loginButton.contentMode = .scaleToFill
        
        var plainConfig = UIButton.Configuration.plain()
        plainConfig.imagePadding = 10
        loginButton.configuration = plainConfig
        loginButton.tintColor = .clear
        loginButton.permissions = ["public_profile", "email"]
        loginButton.delegate = self
        stackViewSocialLogin.addArrangedSubview(loginButton)
    }
    
    func setup() {
        viewModel.delegate = self
        self.lblTnCMessage.delegate = self
        self.addTapGestureToDissmissKeyBoard()
        self.lblTnCMessage.setTermsAndConditionMessage(forSignIn: true)
        self.setButtons()
        self.addFacebookButton()
    }
    
    func setButtons() {
        self.btnLoginWithEmailID.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnSignUp.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnSendOTP.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnLoginWithApple.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnLoginWithGoogle.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.lblTitle.setAttributedTitleWithProperties(
            title: EthosConstants.LoginWithMobile,
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
            alignment: .center,
            foregroundColor: .black,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        
        self.lblHeading.setAttributedTitleWithProperties(
            title: EthosConstants.EnterMobileNumber,
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
            foregroundColor: .black,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        
        self.lblSubHeading.setAttributedTitleWithProperties(
            title: EthosConstants.WeWillSendOTPThroughSMS,
            font: EthosFont.Brother1816Regular(size: 12),
            foregroundColor: .black,
            kern: 0.1
        )
        
        self.btnLoginWithEmailID.setAttributedTitleWithProperties(
            title: EthosConstants.LoginWithEmailId.uppercased(),
            font: EthosFont.Brother1816Regular(size: 12),
            alignment: .center,
            foregroundColor: .black,
            kern: 1
        )
        
        self.btnSignUp.setAttributedTitleWithProperties(
            title: EthosConstants.SignUp.uppercased(),
            font: EthosFont.Brother1816Regular(size: 12),
            alignment: .center,
            foregroundColor: .black,
            kern: 1
        )
        
        self.btnLoginWithApple.setAttributedTitleWithProperties(
            title: EthosConstants.LoginWithApple.uppercased(),
            font: EthosFont.Brother1816Regular(size: 10),
            alignment: .center,
            foregroundColor: .black,
            kern: 1
        )
        
        self.btnLoginWithGoogle.setAttributedTitleWithProperties(
            title: EthosConstants.Google.uppercased(),
            font: EthosFont.Brother1816Regular(size: 10),
            alignment: .center,
            foregroundColor: .black,
            kern: 1
        )
        
    }
    
    func setTextFields() {
        let arrTextFields = [ self.textFieldOTP, self.textFieldPhone]
        for field in arrTextFields {
            field?.delegate = self
        }
        self.textFieldPhone.initWithUIParameters(placeHolderText: EthosConstants.Phone, textInset: 0)
        self.textFieldOTP?.initWithUIParameters(placeHolderText: EthosConstants.EnterOTP, textInset: 0)
        otpSent = false
    }
    
    func showHideOTPView(hide : Bool) {
        self.viewOTP.isHidden = hide
        self.constraintHeightOtpView.constant = hide ? 0 : 56
        self.btnSendOTP.setAttributedTitleWithProperties(
            title: hide ? EthosConstants.SendOTP.uppercased() : EthosConstants.Confirm.uppercased(),
            font: EthosFont.Brother1816Regular(size: 12),
            alignment: .center,
            foregroundColor: .white,
            kern: 1
        )
        self.textFieldOTP.text = ""
        if hide {
            self.remainedSeconds = 0
        } else {
            self.remainedSeconds = resendOtpWaitingTime
        }
        self.view.layoutIfNeeded()
    }
    
    func validateFields() -> Bool {
        var valid = true
        if otpSent == true {
            if self.textFieldOTP.text?.isBlank ?? true {
                self.textFieldOTP.showError(str: EthosConstants.pleaseEnterOTP)
                valid = false
            } else {
                self.textFieldOTP.removeError()
            }
        } else {
            let number = self.textFieldPhone.text ?? ""
            if number.isBlank {
                self.viewTransParent.showBottomError(str: "Please enter phone number")
                self.viewUnderLinePhoneTextField.backgroundColor = EthosColor.red
                self.viewUnderLinePhoneTextField.shake()
                valid = false
            } else if number.isValidPhoneNumber(region: self.country.code ?? "IN") == false {
                self.viewTransParent.showBottomError(str: "Please enter valid phone number")
                self.viewUnderLinePhoneTextField.backgroundColor = EthosColor.red
                self.viewUnderLinePhoneTextField.shake()
                valid = false
            }
            
            if valid == true {
                self.viewTransParent.removeBottomError()
                self.viewUnderLinePhoneTextField.backgroundColor = EthosColor.seperatorColor
            }
        }
        return valid
    }
    
    @IBAction func btnCountryCodeDidTapped(_ sender: UIButton) {
        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosTableViewController.self)) as? EthosTableViewController {
            vc.key = .country
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnSendOTPDidTapped(_ sender: UIButton) {
        if validateFields() {
            if otpSent == true {
                if let countryCode = self.lblCountryCode.text?.replacingOccurrences(of: "+", with: "").trimmingCharacters(in: .whitespacesAndNewlines), let phoneNumber = self.textFieldPhone.text,
                   let otp =  textFieldOTP.text {
                    viewModel.verifyOTP(mobileNumber: countryCode + "-" + phoneNumber, otp: otp)
                }
            } else {
                if let countryCode = self.lblCountryCode.text?.replacingOccurrences(of: "+", with: "").trimmingCharacters(in: .whitespacesAndNewlines),
                 let phoneNumber =  self.textFieldPhone.text {
                    viewModel.sendOTPToMobile(mobileNumber: countryCode + "-" + phoneNumber)
                }
            }
        }
    }
    
    @IBAction func btnLoginWithEmailIdDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: LoginWithEmailViewController.self)) as? LoginWithEmailViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSignUpDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SignUpViewController.self)) as? SignUpViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnLoginWithAppleDidTapped(_ sender: UIButton) {
        signInWithApple()
    }
    
    @IBAction func btnLoginWithGoogleDidTapped(_ sender: UIButton) {
        viewModel.signInWithGoogle(controller: self, signUp: false)
    }
    
    @IBAction func btnResendOTPDidTapped(_ sender: UIButton) {
        if self.btnResendOTP.titleLabel?.text == "Resend OTP" {
            self.showHideOTPView(hide: true)
            if let mobileNumber = self.textFieldPhone.text {
                viewModel.sendOTPToMobile(mobileNumber: mobileNumber)
            }
        }
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gotToHome() {
        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
            UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }?.rootViewController = vc
        }
    }
    
    func signInWithApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginWithMobileViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength = 30
        
        if textField != textFieldOTP {
            self.otpSent = false
        } else {
            maxLength = 6
        }
        
        
        if textField == textFieldPhone {
            maxLength = self.phoneNumberlimit
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
    }
}

extension LoginWithMobileViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}

extension LoginWithMobileViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.updateView {
            if let country : Country = info?[EthosKeys.value] as? Country {
                self.country = country
            }
        }
    }
}

extension LoginWithMobileViewController : AuthenticationViewModelDelegate {
    func updateProfileSuccess(message: String) {
        
    }
    
    func updateProfileFailed(message: String) {
        
    }
    
    func passwordChangeSuccess(message: String) {
        
    }
    
    func passwordChangeFailed(error: String) {
        
    }
    
    func passwordChangeSuccess() {
        
    }
    
    func passwordChangeFailed() {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
    
    
    func resetPasswordLinkSendSuccess() {
        
    }
    
    func resetPasswordLinkSendFailed(error: String) {
        
    }
    
    
    func otpVerifySuccess(token: String, message: String) {
        DispatchQueue.main.async {
            Userpreference.token = token
            self.gotToHome()
        }
    }
    
    func otpVerifyFailed(error: String) {
        var errorMessage = error
        if error == "Session timed-out or incorrect OTP entered." {
            errorMessage = "Incorrect OTP entered. Please try again."
        }
        DispatchQueue.main.async {
            if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController  {
                vc.setActions(title: errorMessage, secondActionTitle: "Ok")
                self.present(vc, animated: true)
            }
        }
    }
    
    func loginSuccess(token: String) {
        DispatchQueue.main.async {
            Userpreference.token = token
            self.gotToHome()
        }
    }
    
    func loginError(error: String) {
        DispatchQueue.main.async {
            if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController  {
                vc.setActions(title: error, secondActionTitle: "Ok")
                self.present(vc, animated: true)
            }
        }
    }
    
    func otpSendSuccess(message: String) {
        DispatchQueue.main.async {
            self.otpSent = true
        }
    }
    
    func otpSendFailed(error: String) {
        DispatchQueue.main.async {
            if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController  {
                vc.setActions(title: error, secondActionTitle: "Ok")
                self.present(vc, animated: true)
            }
        }
    }
}

extension LoginWithMobileViewController : ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            
            if  let email = appleIDCredential.email,  let token = appleIDCredential.identityToken {
                let firstname = appleIDCredential.fullName?.givenName ?? " "
                let lastName = appleIDCredential.fullName?.familyName ?? " "
                saveLoginInfoToDataBase(email: email, token: token, user: appleIDCredential.user) {
                    self.viewModel.loginWithSocial(email: email, firstName: firstname, lastName: lastName, method: "Apple", signUp: false)
                }
            } else  {
                DataBaseModel().checkUserExists(user: appleIDCredential.user) { exist, email  in
                    if exist, let email = email {
                        self.viewModel.loginWithSocial(email: email, firstName: appleIDCredential.fullName?.givenName ?? " ", lastName: appleIDCredential.fullName?.familyName ?? " ", method: "Apple", signUp: false)
                    } else {
                        DispatchQueue.main.async {
                            self.showAlertWithSingleTitle(title: "Login failed!", message: "Open setting ->  \"Apple Id\" -> \"Sign-In & Security\" -> \"Sign in with apple\" -> \"Ethos app\" -> \"Stop using Apple ID\" and Try again")
                        }
                    }
                }
            }
        }
    }
    
    func saveLoginInfoToDataBase(email : String, token : Data, user : String, completion : @escaping () -> ()) {
        DataBaseModel().checkEmailExists(email: email) { exist in
            if exist {
                DataBaseModel().updateTokenForEmail(email: email, token: token, user: user) {
                    completion()
                }
            } else {
                DataBaseModel().saveAppleLoginInfo(email: email, token: token, user: user) {
                    completion()
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
    }
    
}

extension LoginWithMobileViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor(frame: self.view.frame)
    }
    
}


extension LoginWithMobileViewController : LoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields" : "email, first_name, last_name"], tokenString: token, version: nil, httpMethod: .get)
        
        DispatchQueue.main.async {
            self.startIndicator()
        }
        facebookRequest.start {  response, result, error in
            self.stopIndicator()
            guard let result = (result as? [String: Any]), let email = (result["email"] as? String) , error == nil else {
                return
            }
            let firstName = result["first_name"] as? String
            let lastName = result["last_name"] as? String
            
            self.viewModel.loginWithSocial(email: email, firstName: firstName ?? "", lastName: lastName ?? "", method: "Facebook", signUp: false)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        
    }
    
    
}
