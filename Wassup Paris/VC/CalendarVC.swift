//
//  CalendarVCViewController.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/30/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarVC: UIViewController {
    
    let formatter = DateFormatter()
    
    @IBOutlet weak var calendarCollectionView: JTAppleCalendarView!
    @IBOutlet weak var shadowContainerView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var dateRangeSegmentedControl: UISegmentedControl!
    
    var selectedDate: Date?
    
    var delegate: DateCallbackDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTopLabels()
        setupCalendarView()
        setupContainerShadow()
        selectedDate = Date()
        self.blurBackground()
        
    }
    
    func setupCalendarView() {
        calendarCollectionView.calendarDataSource = self
        calendarCollectionView.calendarDelegate = self
        calendarCollectionView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellWithReuseIdentifier: "CalendarCellNib")
        calendarCollectionView.minimumLineSpacing = 0
        calendarCollectionView.minimumInteritemSpacing = 0
    }
    
    func setupContainerShadow(){
        shadowContainerView.layer.shadowColor = UIColor.gray.cgColor
        shadowContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        shadowContainerView.layer.shadowRadius = 12.0
        shadowContainerView.layer.shadowOpacity = 0.7
    }
    
    @IBAction func onMonthlyNavigateButtonClick(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            calendarCollectionView.scrollToSegment(SegmentDestination.previous)
        case 1:
            calendarCollectionView.scrollToSegment(SegmentDestination.next)
        default:
            calendarCollectionView.scrollToSegment(SegmentDestination.next)
        }
    }
    
    @IBAction func onCancelButtonClick(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onValidButtonClick(_ sender: Any){
        if let _ = delegate {
            delegate?.setDate(for: dateRangeSegmentedControl.selectedSegmentIndex, at: selectedDate!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onResetButtonClick(_ sender: Any){
        if let _ = delegate {
            delegate?.resetDate()
        }
        self.dismiss(animated: true, completion: nil)
    }

}

extension CalendarVC:JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCellNib", for: indexPath) as! CalendarCell
        cell.cellLabel.text = cellState.text
        
        toggleCell(for: cell, with: cellState)
        
        return cell
    }
    
    
}

extension CalendarVC: JTAppleCalendarViewDelegate{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2019 01 01")
        let endDate = formatter.date(from: "2020 12 31")
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        toggleCell(for: cell, with: cellState)
        selectedDate = cellState.date
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        toggleCell(for: cell, with: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        updateTopLabels()
    }
    
    func toggleCell(for _cell: JTAppleCell?, with _cellState: CellState){
        guard let validCell = _cell as? CalendarCell else { return }
        if _cellState.isSelected {
            validCell.cellLabel.textColor = UIColor(red: 255/255, green: 65/255, blue: 108/255, alpha: 1)
            validCell.selectedView.isHidden = false
        } else {
            if _cellState.dateBelongsTo == .thisMonth {
                validCell.cellLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
            }else {
                validCell.cellLabel.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
            }
            validCell.selectedView.isHidden = true
        }
    }
    
    func updateTopLabels(){
        calendarCollectionView.visibleDates { (visibleDates) in
             let date = visibleDates.monthDates.first!.date
            
            self.formatter.dateFormat = "yyyy"
            self.yearLabel.text = self.formatter.string(from: date)
            
            self.formatter.dateFormat = "MMMM"
            self.monthLabel.text = self.formatter.string(from: date)
        }
    }
}
