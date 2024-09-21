//
//  PriceSliderTableViewCell.swift
//  Ethos
//
//  Created by Softgrid on 13/08/24.
//

import UIKit

class PriceSliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewTxtFieldMinimum: UIView!
    
    @IBOutlet weak var viewTxtFieldMaximum: UIView!
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var rangeSlider: RangeSeekSlider!
    
    @IBOutlet weak var textFieldMinimum: EthosTextField!
    
    @IBOutlet weak var textFieldMaximum: EthosTextField!
    
    var leftViewMin = UILabel()
    var leftViewMax = UILabel()
    
    var superController : FiltersViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rangeSlider.delegate = self
        self.textFieldMaximum.delegate = self
        self.textFieldMinimum.delegate = self
        self.leftViewMin.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.leftViewMin.setAttributedTitleWithProperties(title: "  \(EthosConstants.RupeesSymbol)  ", font: EthosFont.Brother1816Regular(size: 12), alignment: .center)
        self.viewTxtFieldMaximum.setBorder(borderWidth: 0.5, borderColor: EthosColor.seperatorColor, radius: 5)
        self.viewTxtFieldMinimum.setBorder(borderWidth: 0.5, borderColor: EthosColor.seperatorColor, radius: 5)
        self.leftViewMax.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.leftViewMax.setAttributedTitleWithProperties(title: "  \(EthosConstants.RupeesSymbol)  ", font: EthosFont.Brother1816Regular(size: 12), alignment: .center)

        
    }
    
    func addLowerPriceLimitInModels(completion : () ->
                                    ()) {
        if let index = self.superController?.viewModel.selectedValues.firstIndex(where: { value in
            value.filterModelCode == "pricemin"
        }), let lowerPriceLimit = self.superController?.viewModel.lowerPriceLimit {
            let selectedModel = SelectedFilterData(filterModelName: "Price Min", filterModelCode: "pricemin", filterModelId: nil, filtervalue: FilterValue(
                attributeValueId: lowerPriceLimit,
                attributeValueName: String(lowerPriceLimit)))
            self.superController?.viewModel.selectedValues[index] = selectedModel
            completion()
        } else if let lowerPriceLimit = self.superController?.viewModel.lowerPriceLimit  {
            let selectedModel = SelectedFilterData(filterModelName: "Price Min", filterModelCode: "pricemin", filterModelId: nil, filtervalue: FilterValue(
                attributeValueId: lowerPriceLimit,
                attributeValueName: String(lowerPriceLimit)))
            self.superController?.viewModel.selectedValues.append(selectedModel)
            completion()
        }
    }
    
    func addUpperPriceLimitInModels(completion : () ->
                                    ()) {
        if let index = self.superController?.viewModel.selectedValues.firstIndex(where: { value in
            value.filterModelCode == "pricemax"
        }), let upperPriceLimit = self.superController?.viewModel.upperPriceLimit {
            let selectedModel = SelectedFilterData(filterModelName: "Price Max", filterModelCode: "pricemax", filterModelId: nil, filtervalue: FilterValue(
                attributeValueId: upperPriceLimit,
                attributeValueName: String(upperPriceLimit)))
            
            self.superController?.viewModel.selectedValues[index] = selectedModel
            
            completion()
            
        } else if let upperPriceLimit = self.superController?.viewModel.upperPriceLimit  {
            let selectedModel = SelectedFilterData(filterModelName: "Price Max", filterModelCode: "pricemax", filterModelId: nil, filtervalue: FilterValue(
                attributeValueId: upperPriceLimit,
                attributeValueName: String(upperPriceLimit)))
            
            self.superController?.viewModel.selectedValues.append(selectedModel)
            
            completion()
            
        }
    }
    
    func sliderValueDidChanged(_ sender: RangeSeekSlider) {
        self.superController?.viewModel.lowerPriceLimit = (Int(sender.selectedMinValue.rounded()))
        self.superController?.viewModel.upperPriceLimit = (Int(sender.selectedMaxValue.rounded()))
        
        self.textFieldMinimum.text = "\(Int(sender.selectedMinValue.rounded()).getCommaSeperatedStringValue() ?? "")"
        self.textFieldMaximum.text = "\(Int(sender.selectedMaxValue.rounded()).getCommaSeperatedStringValue() ?? "")"
        self.addLowerPriceLimitInModels {
            self.addUpperPriceLimitInModels {
                self.superController?.viewModel.selectedFilters = self.superController?.viewModel.getSelectedFiltersFromSelectedValues() ?? []
                self.superController?.viewModel.getFilters(site: self.superController?.isForPreOwned ?? false ? .secondMovement : .ethos, screenType: self.superController?.screenType)
            }
        }
    }
    
    func setMinSliderValue(value : Double) {
        self.rangeSlider.selectedMinValue = value
        self.rangeSlider.setNeedsLayout()
        DispatchQueue.main.async {
            self.sliderValueDidChanged(self.rangeSlider)
        }
        
    }
    
    func setMaxSliderValue(value : Double) {
        self.rangeSlider.selectedMaxValue = value
        self.rangeSlider.setNeedsLayout()
        DispatchQueue.main.async {
            self.sliderValueDidChanged(self.rangeSlider)
        }
    }
    
    func setSliderWithValues(viewModel : GetProductViewModel) {
        self.lblTitle.setAttributedTitleWithProperties(title: EthosConstants.price.capitalized, font: EthosFont.Brother1816Medium(size: 12), kern: 1)
        if let minimumValue = viewModel.minPriceLimit,
           let maximumValue = viewModel.maxPriceLimit,
           maximumValue > minimumValue {
            rangeSlider.maxValue = Double(maximumValue)
            rangeSlider.minValue = Double(minimumValue)
            
            
            if let lowerValue = viewModel.lowerPriceLimit,
               let upperValue = viewModel.upperPriceLimit,
               upperValue > lowerValue {
                rangeSlider.selectedMaxValue = Double(upperValue)
                rangeSlider.selectedMinValue = Double(lowerValue)
                self.textFieldMinimum.text = "\(lowerValue.getCommaSeperatedStringValue() ?? "")"
                self.textFieldMaximum.text = "\(upperValue.getCommaSeperatedStringValue() ?? "")"
              
            } else {
                rangeSlider.selectedMaxValue = Double(maximumValue)
                rangeSlider.selectedMinValue = Double(minimumValue)
                self.textFieldMinimum.text = "\(minimumValue.getCommaSeperatedStringValue() ?? "")"
                self.textFieldMaximum.text = "\(maximumValue.getCommaSeperatedStringValue() ?? "")"
             
            }
        }
    }
    
    @IBAction func minimumEditingChanged(_ sender: EthosTextField) {
        
        if  let txt = sender.text?.replacingOccurrences(of: ",", with: ""), let integer = Int(txt) {
            textFieldMinimum.text = integer.getCommaSeperatedStringValue()
        }
     }
    
    
    @IBAction func maximumEditingChanged(_ sender: EthosTextField) {
       
       if  let txt = sender.text?.replacingOccurrences(of: ",", with: ""), let integer = Int(txt) {
           textFieldMaximum.text = integer.getCommaSeperatedStringValue()
       }
    }
    
    
}

extension PriceSliderTableViewCell : RangeSeekSliderDelegate {
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        self.textFieldMinimum.text = "\(Int(slider.selectedMinValue.rounded()).getCommaSeperatedStringValue() ?? "")"
        self.textFieldMaximum.text = "\(Int(slider.selectedMaxValue.rounded()).getCommaSeperatedStringValue() ?? "")"
    }
    
    func didEndTouches(in slider: RangeSeekSlider) {
        sliderValueDidChanged(slider)
    }
}

extension PriceSliderTableViewCell : UITextFieldDelegate {
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
            if string.checkNumeric() == true {
                return true
            } else if string == "" {
                return true
            } else {
                return false
            }
      
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let maxPriceLimit = self.superController?.viewModel.maxPriceLimit ?? 0
        let minPriceLimit = self.superController?.viewModel.minPriceLimit ?? 0
        
        let lowerPriceLimit = self.superController?.viewModel.lowerPriceLimit
        let upperPriceLimit = self.superController?.viewModel.upperPriceLimit
        
        
        
        let text = textField.text ?? ""
        if text != "" {
            if let applyingValue = Int(text.replacingOccurrences(of: ",", with: "")) {
                
                let contains = (minPriceLimit...maxPriceLimit).contains(applyingValue)
                if contains {
                    if textField == self.textFieldMinimum {
                        
                        if let upperPriceLimit = upperPriceLimit {
                            
                            if applyingValue < upperPriceLimit {
                                setMinSliderValue(value: Double(applyingValue))
                            } else {
                                self.superController?.showAlertWithSingleTitle(title: "Minimum price should be lower than Maximum price", message: "")
                                textFieldMinimum.text = self.superController?.viewModel.lowerPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.minPriceLimit?.getCommaSeperatedStringValue()
                            }
                        } else {
                            if applyingValue < maxPriceLimit {
                                setMinSliderValue(value: Double(applyingValue))
                            } else {
                                self.superController?.showAlertWithSingleTitle(title: "Minimum price should be lower than Maximum price", message: "")
                                textFieldMinimum.text = self.superController?.viewModel.lowerPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.minPriceLimit?.getCommaSeperatedStringValue()
                            }
                        }
                    } else if textField == self.textFieldMaximum {
                        
                        if let lowerPriceLimit = lowerPriceLimit {
                           if applyingValue > lowerPriceLimit {
                                setMaxSliderValue(value: Double(applyingValue))
                           } else {
                               textFieldMaximum.text = self.superController?.viewModel.upperPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.maxPriceLimit?.getCommaSeperatedStringValue()
                               self.superController?.showAlertWithSingleTitle(title: "Maximum price should be greater than Minimum price", message: "")
                           }
                        }  else {
                            if applyingValue > minPriceLimit {
                                setMaxSliderValue(value: Double(applyingValue))
                                
                            } else {
                                textFieldMaximum.text = self.superController?.viewModel.upperPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.maxPriceLimit?.getCommaSeperatedStringValue()
                                self.superController?.showAlertWithSingleTitle(title: "Maximum price should be greater than Minimum price", message: "")
                            }
                        }
                    }
                } else {
                    textFieldMinimum.text = self.superController?.viewModel.lowerPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.minPriceLimit?.getCommaSeperatedStringValue()
                    textFieldMaximum.text = self.superController?.viewModel.upperPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.maxPriceLimit?.getCommaSeperatedStringValue()
                    self.superController?.showAlertWithSingleTitle(title: "Please enter the price between \(minPriceLimit.getCommaSeperatedStringValue() ?? "") to \(maxPriceLimit.getCommaSeperatedStringValue() ?? "")", message: "")
                }
            } else {
                textFieldMinimum.text = self.superController?.viewModel.lowerPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.minPriceLimit?.getCommaSeperatedStringValue()
                textFieldMaximum.text = self.superController?.viewModel.upperPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.maxPriceLimit?.getCommaSeperatedStringValue()
                self.superController?.showAlertWithSingleTitle(title: "Please enter valid price", message: "")
                
            }
        } else {
            if textField == self.textFieldMinimum {
                textFieldMinimum.text = self.superController?.viewModel.lowerPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.minPriceLimit?.getCommaSeperatedStringValue()
                self.superController?.showAlertWithSingleTitle(title: "Please enter minimum price", message: "")
            } else {
                textFieldMaximum.text = self.superController?.viewModel.upperPriceLimit?.getCommaSeperatedStringValue() ?? self.superController?.viewModel.maxPriceLimit?.getCommaSeperatedStringValue()
                self.superController?.showAlertWithSingleTitle(title: "Please enter maximum price", message: "")
            }
        }
    }
}
