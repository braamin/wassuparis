//
//  EventsListVC.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/28/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import UIKit
import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

class EventsListVC: UIViewController {

    @IBOutlet weak var DateFilterLabel: UILabel!
    @IBOutlet weak var SortFieldsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var SortBySegmentedControl: UISegmentedControl!
    @IBOutlet weak var EventsTableView: UITableView!
    @IBOutlet weak var EventsCountLabel: UILabel!
    @IBOutlet weak var SortingTopConstraint: NSLayoutConstraint!
    
    var eventsDatasource: EventsDatasource?
    var zoomTransitionManager: ZoomTransitionManager?
    var nhits: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsDatasource = EventsDatasource()
        eventsDatasource?.delegate = self
        EventsTableView.dataSource = eventsDatasource
        EventsTableView.delegate = self
        EventsTableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCellNib")
        
        updateTableView(_atInit: true)
    }
    
    @IBAction func onSortFieldsClick(_ sender: Any){
        // Update parameters' structure at click on segmented control from sorting view
        eventsDatasource?.updateParam(for: SortFieldsSegmentedControl.selectedSegmentIndex, _direction: SortBySegmentedControl.selectedSegmentIndex)
        // Update tableview according to parameters' update
        updateTableView(_atInit: true)
    }
    
    @IBAction func onEditDateFilterButtonClick(_ sender: Any) {
        // Instantiating the calendar popover
        let datePopover = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
        datePopover.delegate = self
        datePopover.selectedDate = eventsDatasource?.urlParam.dateStartFilter.referenceDate
        datePopover.modalPresentationStyle = .overCurrentContext
        datePopover.modalTransitionStyle = .crossDissolve
        self.present(datePopover, animated: true, completion: nil)
    }
    
    @IBAction func onEditFiltersButtonClick(_ sender: Any) {
        // Toggle animation for toggling sorting view
        self.SortingTopConstraint.constant = self.SortingTopConstraint.constant == 0 ? -60 : 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func updateTableView(_atInit: Bool){
        // Asynchronous request on datasource (controller) to get new data. The "_atInit" variable is design to block table data reset on requesting for more data (at bottom scroll)
        eventsDatasource!.getEvents(_atInit: _atInit){ (result) in
            switch result {
            case .success(let eventsDataset):
                self.EventsCountLabel.text = String(eventsDataset.nhits) + " résultat(s)"
                self.nhits = eventsDataset.nhits
                self.EventsTableView.reloadData()
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }

}

extension EventsListVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EventCell else { return }
        
        // Zooming In animation on table view cell
        UIView.animate(withDuration: 0.2, animations: {
            cell.EventInfosView.alpha = 0
        }, completion: { (disappeared) in
            let cardViewFrame = cell.EvenContainerView.superview!.convert(cell.EvenContainerView.frame, to: nil)
            let copyOfCardView = UIImageView(frame: cardViewFrame)
            copyOfCardView.image = cell.EventImageView.image
            copyOfCardView.contentMode = .scaleAspectFill
            copyOfCardView.clipsToBounds = true
            copyOfCardView.layer.cornerRadius = 12
            self.view.addSubview(copyOfCardView)
            cell.EventImageView.isHidden = true
            
            self.zoomTransitionManager = ZoomTransitionManager(cardView: copyOfCardView, cardViewFrame: cardViewFrame, cell: cell)
            
            UIView.animate(withDuration: 0.4, animations: {
                copyOfCardView.layer.cornerRadius = 0
                copyOfCardView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/2)
            }, completion: { (expanded) in
                let eventDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
                eventDetailsVC.modalPresentationStyle = .overCurrentContext
                eventDetailsVC.modalTransitionStyle = .crossDissolve
                eventDetailsVC.delegate = self
                eventDetailsVC.eventImage = self.zoomTransitionManager?.cardView
                eventDetailsVC.event = cell.event
                self.present(eventDetailsVC, animated: true, completion: nil)
            })
        })
        
        
    }
}

extension EventsListVC: AnimatedCellNavigationDelegate {
    
    //Zooming Out animation on table view cell
    func willGoBack() {
        UIView.animate(withDuration: 0.4, animations: {
            guard self.zoomTransitionManager != nil else {return}
            self.zoomTransitionManager!.cardView.frame = self.zoomTransitionManager!.cardViewFrame
            self.zoomTransitionManager!.cardView.layer.cornerRadius = 12
        }) { (shrinked) in
            self.zoomTransitionManager?.cell.EventImageView.isHidden = false
            self.zoomTransitionManager?.cardView.removeFromSuperview()
            UIView.animate(withDuration: 0.2, animations: {
                self.zoomTransitionManager?.cell.EventInfosView.alpha = 1
            })
        }
    }
}

extension EventsListVC: GetMoreDataDelegate {
    
    // Protocol to get more data at bottom scroll
    func getMoreData() {
        if let _ = nhits, let _ = eventsDatasource {
            if(eventsDatasource!.eventList.count < nhits!){
                eventsDatasource?.getMoreData()
                updateTableView(_atInit: false)
            }
        }
    }
}

extension EventsListVC: DateCallbackDelegate {
    
    // Protocole to set search parameter date to the calendar back value (and reset it if asked to do so)
    func setDate(for _tag: Int, at _date: Date) {
        switch _tag{
        case 0:
            eventsDatasource?.updateParam(for: .start, with: .beforeGivenDay, at: _date)
        case 1:
            eventsDatasource?.updateParam(for: .start, with: .onGivenDayOnly, at: _date)
        case 2:
            eventsDatasource?.updateParam(for: .start, with: .afterGivenDay, at: _date)
        default:
            eventsDatasource?.updateParam(for: .start, with: .onGivenDayOnly, at: _date)
        }
        updateTableView(_atInit: true)
    }
    
    func resetDate() {
        eventsDatasource?.resetDateFilters()
        updateTableView(_atInit: true)
    }
}
