//
//  DashBoardTableViewCell.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/22/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class DashboardTableViewCell: UITableViewCell{
    
    var cellDelegate: TripsCellDelegate?
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var whiteBackingView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var mode:String?
    var status:String?
    var origin:String?
    var destination:String?
    var indexPath:IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        whiteBackingView.layer.shadowOpacity = 0.1
        whiteBackingView.layer.shadowOffset = CGSize(width: 0, height: 1)
        whiteBackingView.layer.shadowRadius = 3
        
        routeLabel.adjustsFontSizeToFitWidth = true
        statusLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    //When you press the delete button, the delegate method in TripsViewController is called
    @IBAction func didPressDelete(_ sender: Any) {
        cellDelegate?.didPressDeleteButton((indexPath?.row)!)
        
    }

}

protocol TripsCellDelegate : class {
    func didPressDeleteButton(_ tag: Int)
}
