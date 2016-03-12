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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 0.3
        mutualFriends.textColor = colorHelper.orange
        friendIcon.image = friendIcon.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        friendIcon.tintColor = colorHelper.redOrange
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
