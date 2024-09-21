//
//  LoginWithEmailViewController.swift
//  Ethos
//
//  Created by mac on 28/07/23.
//

import UIKit
import AuthenticationServices
import FBSDKLoginKit
import Mixpanel

class LoginWithEmailViewController: UIViewController {
    
    @IBOutlet weak var textFieldEmail: EthosTextField!
    @IBOutlet weak var textFieldPassword: EthosTextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnLoginWithApple: UIButton!
    @IBOutlet weak var btnLoginWithGoogle: UIButton!
    @IBOutlet weak var stackViewSocialLogin: UIStackView!
    @IBOutlet weak var lblTnCMessage: UITextView!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var btnLoginWithMobileNumber: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var viewModel = AuthenticationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        setTextFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        viewModel.delegate = self
        self.addTapGestureToDissmissKeyBoard()
        self.setTextFields()
        self.setButtons()
        self.lblTnCMessage.setTermsAndConditionMessage(forSignIn: true)
        self.lblTnCMessage.delegate = self
        self.addFacebookButton()
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
    
    func setButtons() {
        self.btnLoginWithMobileNumber.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnSignUp.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnLogin.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnLoginWithApple.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.btnLoginWithGoogle.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        
        self.lblTitle.setAttributedTitleWithProperties(
            title: EthosConstants.LoginWithEmail,
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
            alignment: .center,
            foregroundColor: .black,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        
        self.lblHeading.setAttributedTitleWithProperties(
            title: EthosConstants.loginToYourAccount,
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
            foregroundColor: .black,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        
        self.btnLogin.setAttributedTitleWithProperties(
            title: EthosConstants.Login.uppercased(),
            font: EthosFont.Brother1816Regular(size: 12),
            alignment: .center,
            foregroundColor: .white,
            kern: 1
        )
        
        self.btnLoginWithMobileNumber.setAttributedTitleWithProperties(
            title: EthosConstants.LoginWithMobileNumber.uppercased(),
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
        
        let eyeBtnChangePassword = UIButton()
        
        eyeBtnChangePassword.setImage(UIImage(named: EthosConstants.eye), for: .normal)
        eyeBtnChangePassword.setImage(UIImage(named: EthosConstants.hidePassword), for: .selected)
        
        eyeBtnChangePassword.addTarget(self, action: #selector(showHidePassword(_ :)), for: .touchUpInside)
        
        
        let arrTextFields = [ self.textFieldEmail, self.textFieldPassword]
        for field in arrTextFields {
            field?.delegate = self
        }
        self.textFieldEmail.initWithUIParameters(placeHolderText: EthosConstants.Email, underLineColor: EthosColor.seperatorColor,  textInset: 0)
        self.textFieldPassword.initWithUIParameters(placeHolderText: EthosConstants.Password, rightView: eyeBtnChangePassword,  underLineColor: EthosColor.seperatorColor, textInset: 0)
    }
    
    @objc func showHidePassword(_ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        self.textFieldPassword.isSecureTextEntry = !sender.isSelected
        
    }
    
    @IBAction func btnLoginDidTapped(_ sender: UIButton) {
        if validateFields() {
            if let email = self.textFieldEmail.text , let password = self.textFieldPassword.text {
                viewModel.loginWithEmail(email: email, password: password)
            }
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
    
    @IBAction func btnLoginWithMobileNumberDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        self.viewModel.signInWithGoogle(controller: self, signUp: false)
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnForgotPasswordDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ForgotPasswordViewController.self)) as? ForgotPasswordViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func goToHome() {
        if let vc = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeTabBarController.self)) as? HomeTabBarController {
            UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .last { $0.isKeyWindow }?.rootViewController = vc
        }
    }
    
    func validateFields() -> Bool {
        var valid = true
        if self.textFieldEmail.validateAgainstEmail() == false {
            valid = false
        }
        if self.textFieldPassword.text?.isBlank ?? true {
            self.textFieldPassword.showError(str: EthosConstants.pleaseEnterPassword)
            valid = false
        } else {
            self.textFieldPassword.removeError()
        }
        return valid
    }
    
}


extension LoginWithEmailViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength = 30
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

extension LoginWithEmailViewController : UITextViewDelegate {
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

extension LoginWithEmailViewController : AuthenticationViewModelDelegate {
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
        
    }
    
    func otpVerifyFailed(error: String) {
        
    }
    
    func otpSendFailed(error: String) {
        
    }
    
    func otpSendSuccess(message: String) {
        
    }
    
    func loginSuccess(token: String) {
        DispatchQueue.main.async {
            Userpreference.token = token
            self.goToHome()
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
}

extension LoginWithEmailViewController : ASAuthorizationControllerDelegate {
    
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

extension LoginWithEmailViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor(frame: self.view.frame)
    }
    
}

extension LoginWithEmailViewController : LoginButtonDelegate {
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







