//
//  EventsDatasource.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/28/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import UIKit

class EventsDatasource: NSObject {
    var eventList: [String: Event]
    
    override init() {
        eventList = [:]
    }
    
    func fillUp(with _eventsList: [Event]){
        for event in _eventsList {
            eventList[event.recordid] = event
        }
    }
}

extension EventsDatasource: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCellNib") as! EventCell
        let event = Array(eventList.values)[indexPath.row]
        
        cell.event = event
        
        return cell
    }
    
    
}
