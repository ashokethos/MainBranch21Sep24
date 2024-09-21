//
//  ForgotPasswordViewController.swift
//  Ethos
//
//  Created by mac on 28/07/23.
//

import UIKit
import Mixpanel

class ForgotPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var textFieldEmail: EthosTextField!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
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
        self.setBorders()
    }
    
    func setBorders() {
        self.btnReset.setBorder(borderWidth: 0.5, borderColor: .black, radius: 0)
        self.lblTitle.setAttributedTitleWithProperties(
            title: EthosConstants.ForgotPassword,
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
            alignment: .center,
            foregroundColor: .black,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        
        self.lblSubTitle.setAttributedTitleWithProperties(
            title: EthosConstants.EnterYourRegisteredEmailID,
            font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24),
            foregroundColor: .black,
            lineHeightMultiple: 1.25,
            kern: 0.1
        )
        
        self.btnReset.setAttributedTitleWithProperties(
            title: EthosConstants.Reset.uppercased(),
            font: EthosFont.Brother1816Regular(size: 12),
            alignment: .center,
            foregroundColor: .white,
            kern: 1
        )
    }
    
    func setTextFields() {
        textFieldEmail.delegate = self
        textFieldEmail.initWithUIParameters(placeHolderText: EthosConstants.Email, underLineColor: .clear, textInset: 0)
    }
    
    func removeAllErrors() {
        textFieldEmail.removeError()
    }
    
    func validateFields() -> Bool {
        if self.textFieldEmail.text?.isBlank ?? true {
            self.textFieldEmail.showError(str: EthosConstants.pleaseEnterEmail)
            return false
        }
        if self.textFieldEmail.text?.isValidEmail != true {
            self.textFieldEmail.showError(str: EthosConstants.pleaseEnterValidEmail)
            return false
        }
        return true
    }
    
    @IBAction func btnResetDidTapped(_ sender: UIButton) {
        if validateFields() {
            viewModel.sendResetPasswordLinkOnEmail(email: self.textFieldEmail.text ?? "")
        }
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ForgotPasswordViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        removeAllErrors()
        var maxLength = 30
        if textField == textFieldEmail {
            maxLength = 50
        }
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxLength
    }
}

extension ForgotPasswordViewController : AuthenticationViewModelDelegate {
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
        DispatchQueue.main.async {
            if let alertController = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                alertController.setActions(title: "Email Sent", message: "An email has been sent to you, please follow the instructions to reset your password", secondActionTitle:  "OK", secondAction: {
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(alertController, animated: true)
            }
        }
    }
    
    func resetPasswordLinkSendFailed(error: String) {
        DispatchQueue.main.async {
            self.showAlertWithSingleTitle(title: error, message: "")
        }
    }
}

