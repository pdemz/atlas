//
//  DashBoardTableViewCell.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/22/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var photoImage:UIImage?
    var name:String?
    var mode:String?
    var pending:Bool?
    var origin:String?
    var destination:String?
    
    override func awakeFromNib() {
        modeLabel.textColor = colorHelper.pink
        
        photo.image = photoImage
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
        modeLabel.text = mode!
        routeLabel.text = "\(origin) to \(destination)"
        
        statusHandler()
        
    }
    
    func statusHandler(){
        if pending!{
            statusLabel.text = "\(mode) request pending"
            statusLabel.textColor = colorHelper.maroonOrange
        }else{
            statusLabel.text = "Waiting for \(name) to respond"
            statusLabel.textColor = colorHelper.orange
        }
        
    }
    
}
