//
//  SignUpViewController.swift
//  Ethos
//
//  Created by mac on 28/07/23.
//

import UIKit
import AuthenticationServices
import FBSDKLoginKit
import libPhoneNumber
import Mixpanel

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var textFieldEmail: EthosTextField!
    @IBOutlet weak var textFieldName: EthosTextField!
    @IBOutlet weak var textFieldPassword: EthosTextField!
    @IBOutlet weak var textFieldPhone: EthosTextField!
    @IBOutlet weak var textFieldOTP: EthosTextField!
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var btnResendOTP: UIButton!
    @IBOutlet weak var viewOTP: UIView!
    @IBOutlet weak var btnCheckMark: UIButton!
    @IBOutlet weak var lblSubscriptionMessage: UILabel!
    @IBOutlet weak var lblTnCMessage: UITextView!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var btnSignUpWithApple: UIButton!
    @IBOutlet weak var btnSignUpWithGoogle: UIButton!
    @IBOutlet weak var stackViewSocialLogin: UIStackView!
    @IBOutlet weak var constraintHeightOtpView: NSLayoutConstraint!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblWillSendMessage: UILabel!
    @IBOutlet weak var constraintHeightLblMessage: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var viewTransparentUnderLine: UIView!
    @IBOutlet weak var viewUnderLine: UIView!
    
    var phoneNumberlimit : Int = 10
    
    var country : Country = Country(name: "India", dialCode: "+91", code: "IN") {
        didSet {
            DispatchQueue.main.async {
                self.lblCountryCode.text = self.country.dialCode ?? "+91"
                let util = NBPhoneNumberUtil(metadataHelper: NBMetadataHelper())
                let exampleNumber = try?  util?.getExampleNumber(self.country.code)
                self.phoneNumberlimit = exampleNumber?.nationalNumber.stringValue.count ?? 10
                self.textFieldPhone.text = ""
            }
            
        }
    }
    
    
    var otpSent : Bool? {
        didSet {
            self.showHideOTPView(hide: !(otpSent ?? false))
        }
    }
    
    var timer : Timer?
    
    let resendOtpWaitingTime = 60
    
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
    
    var viewModel = AuthenticationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        self.setTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    func setup() {
        self.lblTnCMessage.delegate = self
        viewModel.delegate = self
        self.addTapGestureToDissmissKeyBoard()
        self.setButtons()
        self.lblTnCMessage.setTermsAndConditionMessage(forSignIn: false)
        self.addFacebookButton()
    }
    
    func setButtons() {
        self.btnCreateAccount.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnSignUpWithApple.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnSignUpWithGoogle.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
       
        
        self.lblTitle.setAttributedTitleWithProperties(
            title: EthosConstants.SignUp,
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
            alignment: .center,
            foregroundColor: .black,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        
        self.lblHeading.setAttributedTitleWithProperties(
            title: EthosConstants.personalDetails,
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
            foregroundColor: .black,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        
        self.lblSubHeading.setAttributedTitleWithProperties(
            title: EthosConstants.createAccountMessage,
            font: EthosFont.Brother1816Regular(size: 12),
            foregroundColor: .black,
            kern: 0.1
        )
        
        self.btnSignUpWithApple.setAttributedTitleWithProperties(
            title: EthosConstants.SignUpWithApple.uppercased(),
            font: EthosFont.Brother1816Regular(size: 10),
            alignment: .center,
            foregroundColor: .black,
            kern: 1
        )
        
        self.btnSignUpWithGoogle.setAttributedTitleWithProperties(
            title: EthosConstants.Google.uppercased(),
            font: EthosFont.Brother1816Regular(size: 10),
            alignment: .center,
            foregroundColor: .black,
            kern: 1
        )
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
    
    func setTextFields() {
        let arrTextFields = [self.textFieldName, self.textFieldOTP,self.textFieldEmail,self.textFieldPassword,self.textFieldPhone]
        for field in arrTextFields {
            field?.delegate = self
        }
        
        let eyeBtnChangePassword = UIButton()
        
        eyeBtnChangePassword.setImage(UIImage(named: EthosConstants.eye), for: .normal)
        eyeBtnChangePassword.setImage(UIImage(named: EthosConstants.hidePassword), for: .selected)
        
        eyeBtnChangePassword.addTarget(self, action: #selector(showHidePassword(_ :)), for: .touchUpInside)
        
        textFieldEmail?.initWithUIParameters(placeHolderText: EthosConstants.Email,  underLineColor: .clear, textInset: 0)
        textFieldName?.initWithUIParameters(placeHolderText: EthosConstants.Name,  underLineColor: .clear, textInset: 0)
        textFieldPassword.initWithUIParameters(placeHolderText: EthosConstants.Password,  rightView: eyeBtnChangePassword, underLineColor: .clear, textInset: 0)
        textFieldPhone.initWithUIParameters(placeHolderText: EthosConstants.Phone,  underLineColor: .clear, textInset: 0)
        textFieldOTP?.initWithUIParameters(placeHolderText: EthosConstants.EnterOTP,  underLineColor: .clear, textInset: 0)
        otpSent = false
    }
    
    @objc func showHidePassword(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.textFieldPassword.isSecureTextEntry = !sender.isSelected
        
    }
    
    func removeAllErrors() {
        let arrTextFields = [self.textFieldName, self.textFieldOTP,self.textFieldEmail,self.textFieldPassword,self.textFieldPhone]
        for field in arrTextFields {
            field?.removeError()
        }
    }
    
    func showHideOTPView(hide : Bool) {
        self.viewOTP.isHidden = hide
        self.constraintHeightOtpView.constant = hide ? 0 : 56
        self.constraintHeightLblMessage.constant = hide ? 50 : 0
        self.lblWillSendMessage.isHidden = !hide
        self.btnCreateAccount.setAttributedTitleWithProperties(
            title: hide ? EthosConstants.CreateAccount.uppercased() : EthosConstants.Confirm.uppercased(),
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
        self.view.layoutSubviews()
    }
    
    @IBAction func btnCountryCodeDidTapped(_ sender: UIButton) {
        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosTableViewController.self)) as? EthosTableViewController {
            vc.key = .country
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnCreateAccountDidTapped(_ sender: UIButton) {
        if validateFields() {
            if otpSent == true {
                if let countryCode = self.lblCountryCode.text?.replacingOccurrences(of: "+", with: "").trimmingCharacters(in: .whitespacesAndNewlines), let phoneNumber = self.textFieldPhone.text,
                    let otp =  textFieldOTP.text  {
                    viewModel.verifyRegisterationOTP(mobileNumber: countryCode + "-" + phoneNumber, otp: otp)
                }
            } else {
                if let countryCode = self.lblCountryCode.text?.replacingOccurrences(of: "+", with: "").trimmingCharacters(in: .whitespacesAndNewlines), let phoneNumber = self.textFieldPhone.text {
                    viewModel.sendRegisterationOTP(mobileNumber:  countryCode + "-" + phoneNumber)
                }
            }
        }
    }
    
    func validateFields() -> Bool {
        var valid = true
        if otpSent == true {
            if self.textFieldOTP.text?.isBlank ?? true {
                self.textFieldOTP.showError(str: EthosConstants.pleaseEnterOTP)
                valid =  false
            } else {
                self.textFieldOTP.removeError()
            }
        } else {
            
            if self.textFieldEmail.validateAgainstEmail() == false {
                valid =  false
            }
            
            if self.textFieldName.validateAgainstFullName() == false {
                valid =  false
            }
            
            if self.textFieldPassword.validationAgainstPassword() == false {
                valid =  false
            }
            
            let text = self.textFieldPhone.text ?? ""
            var validPhoneNumber = true
            
            if text.isBlank {
                self.viewTransparentUnderLine.showBottomError(str: "Please enter phone number")
                self.viewUnderLine.backgroundColor = EthosColor.red
                valid = false
                validPhoneNumber = false
            } else if text.isValidPhoneNumber(region: self.country.code ?? "IN") == false {
                self.viewTransparentUnderLine.showBottomError(str: "Please enter valid phone number")
                self.viewUnderLine.backgroundColor = EthosColor.red
                valid = false
                validPhoneNumber = false
            }
            
            if validPhoneNumber == true {
                self.viewTransparentUnderLine.removeBottomError()
                self.viewUnderLine.backgroundColor = EthosColor.seperatorColor
            }
            
        }
        
        return valid
    }
    
    @IBAction func btnSignUpWithAppleDidTapped(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @IBAction func btnSignUpWithGoogleDidTapped(_ sender: UIButton) {
        viewModel.signInWithGoogle(controller: self, signUp: true)
    }
    
    
    @IBAction func btnResendOTPDidTapped(_ sender: UIButton) {
        if self.btnResendOTP.titleLabel?.text == "Resend OTP" {
            self.showHideOTPView(hide: true)
              if let countryCode = self.lblCountryCode.text?.replacingOccurrences(of: "+", with: "").trimmingCharacters(in: .whitespacesAndNewlines), let mobileNumber = self.textFieldPhone.text {
                viewModel.sendRegisterationOTP(mobileNumber: countryCode + "-" + mobileNumber)
            }
        }
    }
    
    @IBAction func btnCheckMarkDidTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gotToHome() {
        DispatchQueue.main.async {
            if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
                UIApplication
                    .shared
                    .connectedScenes
                    .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                    .last { $0.isKeyWindow }?.rootViewController = vc
            }
        }
    }
}

extension SignUpViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength = 30
        
        if textField != textFieldOTP {
            self.otpSent = false
        } else {
            maxLength = 6
        }
        
        if textField == textFieldName {
            maxLength = 30
        }
        
        if textField == textFieldPhone {
            maxLength = self.phoneNumberlimit
        }
        
        if textField == textFieldPassword {
            maxLength = 20
        }
        
        if textField == textFieldEmail {
            maxLength = 50
        }
    
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
        
    }
    
}

extension SignUpViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: DoccumentViewController.self)) as? DoccumentViewController
        
        if URL.scheme == EthosIdentifiers.terms {
            if let vc = vc {
                vc.title  = EthosConstants.TermsOfUse
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return false
        } else  if URL.scheme == EthosIdentifiers.privacy {
            if let vc = vc {
                vc.title  = EthosConstants.PrivacyPolicy
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return false
        }
        return true
    }
}

extension SignUpViewController : AuthenticationViewModelDelegate {
    func updateProfileSuccess(message: String) {
        
    }
    
    func updateProfileFailed(message: String) {
        
    }
    
    func passwordChangeSuccess(message: String) {
        
    }
    
    func passwordChangeFailed(error: String) {
        
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
            if let mobileNumber = self.textFieldPhone.text, let name = self.textFieldName.text , let email = self.textFieldEmail.text, let password = self.textFieldPassword.text {
              
                let firstname = name.getFirstNameAndLastNameFromString().0
                let lastname = name.getFirstNameAndLastNameFromString().1
                
                self.viewModel.registerUser(firstname: firstname, lastName: lastname, mobileNumber: mobileNumber, email: email, password: password)
            }
        }
    }
    
    func otpVerifyFailed(error: String) {
        DispatchQueue.main.async {
            if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController  {
                vc.setActions(title:  error.replacingOccurrences(of: "allready", with: "already"), secondActionTitle: "Ok")
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
                vc.setActions(title: error.replacingOccurrences(of: "allready", with: "already"), secondActionTitle: "Ok")
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
                vc.setActions(title:  error.replacingOccurrences(of: "allready", with: "already"), secondActionTitle: "Ok")
                self.present(vc, animated: true)
            }
        }
    }
}

extension SignUpViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.updateView {
            if let country : Country = info?[EthosKeys.value] as? Country {
                self.country = country
            }
        }
    }
}

extension SignUpViewController : ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            if  let email = appleIDCredential.email,  let token = appleIDCredential.identityToken {
                let firstname = appleIDCredential.fullName?.givenName ?? " "
                let lastName = appleIDCredential.fullName?.familyName ?? " "
                saveLoginInfoToDataBase(email: email, token: token, user: appleIDCredential.user) {
                    self.viewModel.loginWithSocial(email: email, firstName: firstname, lastName: lastName, method: "Apple", signUp: true)
                }
            } else {
                DataBaseModel().checkUserExists(user: appleIDCredential.user) { exist, email  in
                    if exist, let email = email {
                        self.viewModel.loginWithSocial(email: email, firstName: appleIDCredential.fullName?.givenName ?? " ", lastName: appleIDCredential.fullName?.familyName ?? " ", method: "Apple", signUp: true)
                    } else {
                        DispatchQueue.main.async {
                            self.showAlertWithSingleTitle(
                                title: "Login failed!",
                                message: "Open setting ->  \"Apple Id\" -> \"Sign-In & Security\" -> \"Sign in with apple\" -> \"Ethos app\" -> \"Stop using Apple ID\" and Try again"
                            )
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

extension SignUpViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor(frame: self.view.frame)
    }
}

extension SignUpViewController : LoginButtonDelegate {
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
            
            self.viewModel.loginWithSocial(email: email, firstName: firstName ?? "", lastName: lastName ?? "", method: "Facebook", signUp: true)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        
    }
    
    
}
