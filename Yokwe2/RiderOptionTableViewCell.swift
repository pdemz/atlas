//
//  RiderOptionTableViewCell.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/29/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit

class RiderOptionTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var addedTime: UILabel!
    @IBOutlet weak var mutualFriends: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        photo.layer.masksToBounds = false
        //photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
        self.name.textColor = colorHelper.orange
        mutualFriends.textColor = UIColor.black
        
        mutualFriends.adjustsFontSizeToFitWidth = true
        
        //friendIcon.image = friendIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        //friendIcon.tintColor = UIColor.blackColor()
        
        mutualFriends.alpha = 0.7
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
