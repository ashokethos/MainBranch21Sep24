//
//  VibrationHelper.swift
//  Ethos
//
//  Created by Softgrid on 26/04/24.
//

import UIKit
import AudioToolbox

class VibrationHelper {

    static func vibrate(completion : (() -> ())? = nil) {
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {
            
        }
    }
    
    
}
