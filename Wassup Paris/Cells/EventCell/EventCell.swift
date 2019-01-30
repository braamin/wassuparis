//
//  EventCell.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/28/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    var event: EventsDataset.Event? {
        didSet {
            EventNameLabel.text = event?.fields.title
            EventStartDayLabel.text = event?.fields.getTimeComponent(_timeComponent: .dayStart)
            EventStartMonthLabel.text = event?.fields.getTimeComponent(_timeComponent: .monthStart)
            EventEndDayLabel.text = event?.fields.getTimeComponent(_timeComponent: .dayEnd)
            EventEndMonthLabel.text = event?.fields.getTimeComponent(_timeComponent: .monthEnd)
            EventAddressLabel.text = event?.fields.address
        }
    }
    
    @IBOutlet weak var EventNameLabel: UILabel!
    @IBOutlet weak var EventImageView: UIImageView!
    @IBOutlet weak var EventAddressLabel: UILabel!
    @IBOutlet weak var EventStartDayLabel: UILabel!
    @IBOutlet weak var EventStartMonthLabel: UILabel!
    @IBOutlet weak var EventEndDayLabel: UILabel!
    @IBOutlet weak var EventEndMonthLabel: UILabel!
    @IBOutlet weak var EvenContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        EvenContainerView.layer.cornerRadius = 8
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
