//
//  EthosTextField.swift
//  Ethos
//
//  Created by mac on 31/07/23.
//

import UIKit

class EthosTextField: UITextField {
    private var placeHolderColor = UIColor.black
    private let underLineView = UIView()
    private var placeHolderText : String = ""
    private let errorLabel = UIButton()
    private var errTextColor = UIColor.red
    private var underLineColor = EthosColor.seperatorColor
    private var errUnderLineColor = UIColor.red
    private var txtColor = UIColor.black
    private var txtTintColor = UIColor.red
    private var errImage : UIImage? = UIImage(named: EthosConstants.required)
    private var textInset : CGFloat = 0
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: CGFloat(Int((leftView?.frame.maxX ?? 0) + textInset)), y: CGFloat(Int(bounds.minY)), width: bounds.maxX - (rightView?.bounds.width ?? 0), height: bounds.maxY)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: CGFloat(Int((leftView?.frame.maxX ?? 0) + textInset)), y: CGFloat(Int(bounds.minY)), width: bounds.maxX - (rightView?.bounds.width ?? 0), height: bounds.maxY)
    }
    
    func initWithUIParameters (
        placeHolderText : String,
        textColor : UIColor = .black,
        txtTintColor : UIColor = .red,
        leftView : UIView? = nil,
        rightView : UIView? = nil,
        placeholderColor : UIColor = .black,
        underLineColor : UIColor = .clear,
        errUnderLineColor : UIColor = .red,
        errTextColor : UIColor = UIColor.red,
        errImage : UIImage? = UIImage(named: EthosConstants.required),
        leftViewHeight : Int = 24,
        leftViewWidth : Int = 24,
        rightViewWidth : Int = 24,
        rightViewHeight : Int = 24,
        textInset : CGFloat = 10
    ) {
        self.txtColor = textColor
        self.txtTintColor = txtTintColor
        self.placeHolderColor = placeholderColor
        self.underLineColor = underLineColor
        self.errUnderLineColor = errUnderLineColor
        self.errTextColor = errTextColor
        self.errImage = errImage
        self.placeHolderColor = placeholderColor
        self.placeHolderText = placeHolderText
        self.font = EthosFont.Brother1816Regular(size: 12)
        self.textColor = txtColor
        self.tintColor = txtTintColor
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeHolderText, attributes: [NSAttributedString.Key.foregroundColor : self.placeHolderColor, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12)])
       
        let frame = self.frame
        underLineView.frame = CGRect(x: Int(frame.minX), y: Int(frame.maxY), width: Int(frame.width), height: 1)
        underLineView.backgroundColor = underLineColor
        
        
        errorLabel.setTitleColor(self.errTextColor, for: .normal)
        errorLabel.setTitle( " ", for: .normal)
        errorLabel.titleLabel?.font = EthosFont.Brother1816Regular(size: 10)
        errorLabel.titleLabel?.textAlignment = .left
        errorLabel.contentHorizontalAlignment = .leading
        errorLabel.setImage(errImage, for: .normal)
        errorLabel.frame = CGRect(x: Int(frame.minX), y:  Int(frame.maxY) + 5, width: Int(frame.width), height: 20)
        errorLabel.isHidden = true
        
        
        if  let view = leftView {
            self.leftViewMode = .always
            view.frame = CGRect(x: 10, y: Int(self.frame.height)/2 - leftViewWidth/2, width: leftViewWidth, height: leftViewHeight)
            self.leftView = view
        }
        
        if  let view = rightView {
            self.rightViewMode = .always
            view.frame = CGRect(x: Int(self.frame.maxX) - rightViewWidth, y: Int(self.frame.height)/2 - rightViewWidth/2, width: rightViewWidth, height: rightViewHeight)
            self.rightView = view
        }
        
        self.textInset = textInset
        
        self.superview?.addSubview(errorLabel)
        self.superview?.addSubview(underLineView)
    }
    
    func showErrorWithoutMessage(){
        self.shake()
        self.backgroundColor = .red
    }
    
    func showError(str : String) {
        self.underLineView.frame = CGRect(x: Int(frame.minX), y: Int(frame.maxY), width: Int(frame.width), height: 1)
        self.errorLabel.frame = CGRect(x: Int(frame.minX), y:  Int(frame.maxY) + 5, width: Int(frame.width), height: 20)
        self.errorLabel.setTitle(" " + str, for: .normal)
        self.errorLabel.isHidden = false
        self.underLineView.backgroundColor = self.errUnderLineColor
        self.errorLabel.shake()
    }
    
    func removeError() {
        self.errorLabel.isHidden = true
        self.underLineView.backgroundColor = self.underLineColor
        self.backgroundColor = .white
    }
    
    func validateAgainstFullName() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter name")
            valid = false
        } else if self.text?.getFirstNameAndLastNameFromString().0 == "" || self.text?.getFirstNameAndLastNameFromString().1 == "" {
            self.showError(str: "Please enter full name")
            valid = false
        } else if self.text?.count ?? 0 < 3 {
            self.showError(str: "Please enter at least 3 characters")
            valid = false
        } else if self.text?.count ?? 0 > 30 {
            self.showError(str: "Please enter maximum 30 characters")
            valid = false
        } else if self.text?.containsOneSpecialCharacterForNCS ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsHtmlCharacters ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsOneNumericValue ?? true {
            self.showError(str: "Numbers not allowed")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
    
    func validateAgainstName() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter name")
            valid = false
        } else if self.text?.count ?? 0 < 3 {
            self.showError(str: "Please enter at least 3 characters")
            valid = false
        } else if self.text?.count ?? 0 > 30 {
            self.showError(str: "Please enter maximum 30 characters")
            valid = false
        } else if self.text?.containsOneSpecialCharacterForNCS ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsHtmlCharacters ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsOneNumericValue ?? true {
            self.showError(str: "Numbers not allowed")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
    
    func validateAgainstCity() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter city")
            valid = false
        } else if self.text?.count ?? 0 < 3 {
            self.showError(str: "Please enter at least 3 characters")
            valid = false
        } else if self.text?.count ?? 0 > 30 {
            self.showError(str: "Please enter maximum 30 characters")
            valid = false
        } else if self.text?.containsOneSpecialCharacterForNCS ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsHtmlCharacters ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsOneNumericValue ?? true {
            self.showError(str: "Numbers not allowed")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
    
    func validateAgainstLocation() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter location")
            valid = false
        } else if self.text?.count ?? 0 < 3 {
            self.showError(str: "Please enter at least 3 characters")
            valid = false
        } else if self.text?.count ?? 0 > 30 {
            self.showError(str: "Please enter maximum 30 characters")
            valid = false
        } else if self.text?.containsOneSpecialCharacterForNCS ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsHtmlCharacters ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsOneNumericValue ?? true {
            self.showError(str: "Numbers not allowed")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
    
    func validateAgainstSubject() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter subject")
            valid = false
        } else if self.text?.count ?? 0 < 3 {
            self.showError(str: "Please enter at least 3 characters")
            valid = false
        } else if self.text?.count ?? 0 > 30 {
            self.showError(str: "Please enter maximum 30 characters")
            valid = false
        } else if self.text?.containsHtmlCharacters ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsOneSpecialCharacterForNCS ?? true {
            self.showError(str: "Special characters not allowed")
            valid = false
        } else if self.text?.containsOneNumericValue ?? true {
            self.showError(str: "Numbers not allowed")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
    
    func validateAgainstMessage() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: EthosConstants.pleaseEnterMessage)
            valid = false
        } else if self.text?.count ?? 0 < 5 {
            self.showError(str: EthosConstants.PleaseEnterAtLeast5Characters)
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
    
    func validateAgainstPhoneNumber(region : String = Locale.current.regionCode ?? "IN") -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter phone number")
            valid = false
        } else if self.text?.isValidPhoneNumber(region: region) == false {
            self.showError(str: "Please enter valid phone number")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
    
    func validateAgainstEmail() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter email address")
            valid = false
        } else if self.text?.isValidEmail == false {
            self.showError(str: "Please enter valid email address")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
    
    func validationAgainstPassword() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter password")
            valid = false
        } else if self.text?.count ?? 0 < 8 {
            self.showError(str: "Password length should be minimum 8 characters")
            valid = false
        } else if !(self.text?.containsOneCapitalLetter ?? true) {
            self.showError(str: "Password should contain an upper case letter")
            valid = false
        } else if !(self.text?.containsOneSmallLetter ?? true) {
            self.showError(str: "Password should contain a lower case letter")
            valid = false
        } else if !(self.text?.containsOneNumericValue ?? true) {
            self.showError(str: "Password should contain a digit")
            valid = false
        } else if !(self.text?.containsOneSpecialCharacter ?? true) {
            self.showError(str: "Password should contain a special character")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
       
        return valid
        
    }
    
    func validationAgainstNewPassword() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter new password")
            valid = false
        } else if self.text?.count ?? 0 < 8 {
            self.showError(str: "Password length should be minimum 8 characters")
            valid = false
        } else if !(self.text?.containsOneCapitalLetter ?? true) {
            self.showError(str: "Password should contain an upper case letter")
            valid = false
        } else if !(self.text?.containsOneSmallLetter ?? true) {
            self.showError(str: "Password should contain a lower case letter")
            valid = false
        } else if !(self.text?.containsOneNumericValue ?? true) {
            self.showError(str: "Password should contain a digit")
            valid = false
        } else if !(self.text?.containsOneSpecialCharacter ?? true) {
            self.showError(str: "Password should contain a special character")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
       
        return valid
        
    }
    
    func validateAgainstOTP() -> Bool {
        var valid = true
        if self.text?.isBlank ?? true {
            self.showError(str: "Please enter otp")
            valid = false
        }
        
        if valid == true {
            self.removeError()
        }
        
        return valid
    }
}
