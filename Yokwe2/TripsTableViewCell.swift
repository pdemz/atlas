//
//  TripsTableViewCell.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/2/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class TripsTableViewCell: UITableViewCell {

    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var to: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var isActive = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func pressedDelete(_ sender: AnyObject) {
    }
    

}
