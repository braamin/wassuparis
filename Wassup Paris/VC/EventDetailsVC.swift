//
//  EventDetailsVC.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/30/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import UIKit

class EventDetailsVC: UIViewController {
    
    var delegate: AnimatedCellNavigationDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dayStartLabel: UILabel!
    @IBOutlet weak var monthStartLabel: UILabel!
    @IBOutlet weak var yearStartLabel: UILabel!
    @IBOutlet weak var dayEndLabel: UILabel!
    @IBOutlet weak var monthEndLabel: UILabel!
    @IBOutlet weak var yearEndLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTagsLabel: UILabel!
    
    var eventImage: UIImageView?
    
    var event: EventsDataset.Event?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Updating the view with the event's data
        if let _ = event {
            titleLabel.text = event?.fields.title
            addressLabel.text = event?.fields.address
            dayStartLabel.text = event?.fields.getTimeComponent(_timeComponent: .dayStart)
            monthStartLabel.text = event?.fields.getTimeComponent(_timeComponent: .monthStart)
            yearStartLabel.text = event?.fields.getTimeComponent(_timeComponent: .yearStart)
            dayEndLabel.text = event?.fields.getTimeComponent(_timeComponent: .dayEnd)
            monthEndLabel.text = event?.fields.getTimeComponent(_timeComponent: .monthEnd)
            yearEndLabel.text = event?.fields.getTimeComponent(_timeComponent: .yearEnd)
            eventTagsLabel.text = event?.fields.tags
            descriptionTextView.text = event?.fields.description
        }
        
        if let _ = eventImage{
            eventImageView.image = eventImage?.image
        }
    }
    
    @IBAction func onBackToEventListButtonClick(_ sender: Any) {
        guard let delegate = delegate else { return }
        delegate.willGoBack()
        self.dismiss(animated: true, completion: nil)
    }

}
