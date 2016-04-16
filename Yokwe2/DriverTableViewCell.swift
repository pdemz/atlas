//
//  DriverTableViewCell.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/15/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class DriverTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var mutualFriends: UILabel!
    @IBOutlet weak var friendIcon: UIImageView!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true

        mutualFriends.textColor = colorHelper.orange
        friendIcon.image = friendIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        friendIcon.tintColor = colorHelper.orange
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
