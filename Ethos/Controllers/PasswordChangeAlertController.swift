//
//  PasswordChangeAlertController.swift
//  Ethos
//
//  Created by mac on 02/08/23.
//

import UIKit
import Mixpanel

class PasswordChangeAlertController: UIViewController {
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var viewGrey: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSecondAction: UIButton!
    @IBOutlet weak var textFieldCurrentPassword: EthosTextField!
    @IBOutlet weak var textFieldChangePassword: EthosTextField!
    @IBOutlet weak var textFieldConfirmPassword: EthosTextField!
    @IBOutlet weak var btnTransParentBackGround : UIButton!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    
    var delegate : SuperViewDelegate?
    var viewModel = AuthenticationViewModel()
    let bottomConstant = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        setTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true)
    }
    
    func setup() {
        setKeyBoard()
        viewModel.delegate = self
        self.lblTitle.setAttributedTitleWithProperties(title: EthosConstants.ChangePassword, font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), alignment: .center, kern: 0.1)
       
        
        self.viewAlert.clipsToBounds = true
        self.viewAlert.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.viewAlert.layer.cornerRadius = 20
        
        viewGrey.setBorder(borderWidth: 0.5, borderColor: .clear, radius: 2.5)
    }
    
    func setKeyBoard() {
        self.addTapGestureToDissmissKeyBoard()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func setTextFields() {
        self.textFieldChangePassword.isSecureTextEntry = true
        self.textFieldConfirmPassword.isSecureTextEntry = true
        self.textFieldCurrentPassword.isSecureTextEntry = true
        
        self.textFieldChangePassword.delegate = self
        self.textFieldConfirmPassword.delegate = self
        self.textFieldCurrentPassword.delegate = self
        
        
        let eyeBtnCurrentPassword = UIButton()
        eyeBtnCurrentPassword.setImage(UIImage(named: EthosConstants.eye), for: .normal)
        eyeBtnCurrentPassword.setImage(UIImage(named: EthosConstants.hidePassword), for: .selected)
        eyeBtnCurrentPassword.addTarget(self, action: #selector(showCurrentPassword), for: .touchUpInside)
        
        let eyeBtnConfirmPassword = UIButton()
        eyeBtnConfirmPassword.setImage(UIImage(named: EthosConstants.eye), for: .normal)
        eyeBtnConfirmPassword.setImage(UIImage(named: EthosConstants.hidePassword), for: .selected)
        eyeBtnConfirmPassword.addTarget(self, action: #selector(showConfirmPassword), for: .touchUpInside)
        
        let eyeBtnChangePassword = UIButton()
        eyeBtnChangePassword.setImage(UIImage(named: EthosConstants.eye), for: .normal)
        eyeBtnChangePassword.setImage(UIImage(named: EthosConstants.hidePassword), for: .selected)
        eyeBtnChangePassword.addTarget(self, action: #selector(showChangePassword), for: .touchUpInside)
        
        self.textFieldCurrentPassword.initWithUIParameters(placeHolderText: EthosConstants.CurrentPassword, rightView: eyeBtnCurrentPassword, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.textFieldConfirmPassword.initWithUIParameters(placeHolderText: EthosConstants.ConfirmPassword, rightView: eyeBtnConfirmPassword, underLineColor: EthosColor.seperatorColor, textInset: 0)
        self.textFieldChangePassword.initWithUIParameters(placeHolderText: EthosConstants.NewPassword, rightView: eyeBtnChangePassword, underLineColor: EthosColor.seperatorColor,textInset: 0)
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            constraintBottom.constant =  keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        constraintBottom.constant = 50
        self.view.layoutIfNeeded()
    }
    
    @objc func showCurrentPassword(_ sender : UIButton) {
        self.textFieldCurrentPassword.isSecureTextEntry = !self.textFieldCurrentPassword.isSecureTextEntry
        sender.isSelected = !self.textFieldCurrentPassword.isSecureTextEntry
    }
    
    @objc func showChangePassword(_ sender : UIButton) {
        self.textFieldChangePassword.isSecureTextEntry = !self.textFieldChangePassword.isSecureTextEntry
        sender.isSelected = !self.textFieldChangePassword.isSecureTextEntry
    }
    
    @objc func showConfirmPassword(_ sender : UIButton) {
        self.textFieldConfirmPassword.isSecureTextEntry = !self.textFieldConfirmPassword.isSecureTextEntry
        sender.isSelected = !self.textFieldConfirmPassword.isSecureTextEntry
    }
    
    func validateFields() -> Bool {
        
        var valid = true
        
        if self.textFieldCurrentPassword.text?.isBlank ?? true {
            self.textFieldCurrentPassword.showError(str: EthosConstants.pleaseEnterPassword)
            valid = false
        } else {
            self.textFieldCurrentPassword.removeError()
        }
        
        if self.textFieldChangePassword.validationAgainstNewPassword() == false {
            valid = false
        }
        
        if self.textFieldConfirmPassword.text?.isBlank ?? true {
            self.textFieldConfirmPassword.showError(str: EthosConstants.pleaseConfirmNewPassword)
            valid = false
        } else if self.textFieldChangePassword.text != self.textFieldConfirmPassword.text {
            self.textFieldConfirmPassword.showError(str: EthosConstants.passwordsDoNotMatched)
            valid = false
        }
        
        return valid
    }
    
    
    @IBAction func btnSaveDidTapped(_ sender: UIButton) {
        if validateFields() {
            if let token = Userpreference.token {
                viewModel.changePasswordForLoggedInUser(currentPassword: self.textFieldCurrentPassword.text ?? "", newPassword: self.textFieldConfirmPassword.text ?? "", token: token)
            }
        }
    }
    
    @IBAction func btnForgotPasswordDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.route])
        }
    }
    
    @IBAction func btnTransParentBackGroundDidTapped(_ sender: UIButton) {
        if (self.textFieldConfirmPassword.isEditing || self.textFieldChangePassword.isEditing || self.textFieldCurrentPassword.isEditing) == false {
            self.view.endEditing(true)
            self.dismiss(animated: true)
        }
    }
    
    func removeAllErrors() {
        let arrTextFields = [self.textFieldConfirmPassword, self.textFieldChangePassword,self.textFieldCurrentPassword]
        for field in arrTextFields {
            field?.removeError()
        }
    }
}

extension PasswordChangeAlertController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        removeAllErrors()
        let maxLength = 20
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
    }
}

extension PasswordChangeAlertController : AuthenticationViewModelDelegate {
    func updateProfileSuccess(message: String) {
        
    }
    
    func updateProfileFailed(message: String) {
        
    }
    
    func passwordChangeSuccess(message: String) {
        DispatchQueue.main.async {
            if let alertController = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                alertController.setActions(title: message, message: "", secondActionTitle: EthosConstants.Done, secondAction:  {
                    self.dismiss(animated: true)
                })
                self.present(alertController, animated: true)
            }
        }
    }
    
    func passwordChangeFailed(error: String) {
            DispatchQueue.main.async {
                self.showAlertWithSingleTitle(title: error, message: "")
        }
    }
    
    func loginSuccess(token: String) {
        
    }
    
    func loginError(error: String) {
        
    }
    
    func otpSendSuccess(message: String) {
        
    }
    
    func otpSendFailed(error: String) {
        
    }
    
    func otpVerifySuccess(token: String, message: String) {
        
    }
    
    func otpVerifyFailed(error: String) {
        
    }
    
    func resetPasswordLinkSendSuccess() {
        
    }
    
    func resetPasswordLinkSendFailed(error: String) {
        
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
    
    
}
