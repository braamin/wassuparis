//
//  CalendarCell.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/30/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
