//
//  InfoCollectionViewCell.swift
//  WeatherPlus
//
//  Created by Seiken Dojo on 2023-01-31.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {

    //MARK: IBOutlets
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func generateCell(weatherInfo: WeatherInfo) {
        infoLabel.text = weatherInfo.infoText
        infoLabel.adjustsFontSizeToFitWidth = true

        if weatherInfo.image != nil {
            nameLabel.isHidden = true
            infoImageView.isHidden = false
            infoImageView.image = weatherInfo.image
        } else {
            nameLabel.isHidden = false
            infoImageView.isHidden = true
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.text = weatherInfo.nameText
        }
    }
}
