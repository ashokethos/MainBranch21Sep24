//
//  FollowUsTableViewCell.swift
//  Ethos
//
//  Created by Ashok kumar on 28/10/24.
//

import UIKit

class FollowUsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func btnXdidTapped(_ sender: UIButton) {
        
        if let url = URL(string: "https://twitter.com/ethoswatches"),UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if success {
                    print("URL opened successfully")
                } else {
                    print("Failed to open URL")
                }
            }
        }
    }
    
    @IBAction func btnLinkedInDidTapped(_ sender: UIButton) {
        if let url = URL(string: "https://in.linkedin.com/company/ethoswatchboutiques"),UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url){ success in
                if success {
                    print("URL opened successfully")
                } else {
                    print("Failed to open URL")
                }
            }
        }
        
    }
    
    
    @IBAction func btnInstaDidTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.instagram.com/ethoswatches/"),UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url){ success in
                if success {
                    print("URL opened successfully")
                } else {
                    print("Failed to open URL")
                }
            }
        }
        
    }
    
    
    @IBAction func btnFBDidTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.facebook.com/Ethos.Watch.Boutiques"),UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url){ success in
                if success {
                    print("URL opened successfully")
                } else {
                    print("Failed to open URL")
                }
            }
        }
        
    }
    
    
    @IBAction func btnYoutubeDidTapped(_ sender: UIButton) {
        if let url = URL(string: "https://www.youtube.com/user/EthosWatchBoutiques"),UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url){ success in
                if success {
                    print("URL opened successfully")
                } else {
                    print("Failed to open URL")
                }
            }
        }
        
    }
    
}
