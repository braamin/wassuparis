//
//  EventStruct.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/28/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import Foundation
import UIKit

struct EventsDataset: Codable{
    
    struct DatasetParam: Codable {
        let timezone: String
        let rows: Int
    }
    
    struct Event: Codable {
        
        struct EventDetails: Codable{
            
            let uid: String
            let imageUrl: String?
            let title: String?
            let description: String?
            let dateStart: Date
            let dateEnd: Date
            let imageThumbUrl: String?
            let address: String
            let coordinates: [Double]
            let tags: String?
            
            enum CodingKeys: String, CodingKey {
                case uid
                case description
                case address
                case title
                case tags
                
                case imageUrl = "image"
                case dateStart = "date_start"
                case dateEnd = "date_end"
                case imageThumbUrl = "image_thumb"
                case coordinates = "latlon"
            }
            
            enum SplitDateComponent {
                case dayStart
                case monthStart
                case yearStart
                case dayEnd
                case monthEnd
                case yearEnd
            }
            
            func getTimeComponent(_timeComponent: SplitDateComponent)->String{
                switch _timeComponent {
                case .dayStart:
                    return dateStart.dayString
                case .monthStart:
                    return dateStart.monthString
                case .yearStart:
                    return dateStart.yearString
                case .dayEnd:
                    return dateEnd.dayString
                case .monthEnd:
                    return dateEnd.monthString
                case .yearEnd:
                    return dateEnd.yearString
                }
            }
        }
        
        let datasetid: String
        let recordid: String
        let fields: EventDetails
    }
    
    let nhits: Int
    let parameters: DatasetParam
    let records: [Event]
}

struct ZoomTransitionManager {
    var cardView: UIImageView
    var cardViewFrame: CGRect
    var cell: EventCell
}

struct UrlParamManager {
    
    enum OrderBy: CustomStringConvertible {
        
        case none
        case dateStart
        case dateEnd
        
        var description: String {
            switch self {
            case .none:
                return ""
            case .dateStart:
                return "date_start"
            case .dateEnd:
                return "date_end"
            }
        }
    }
    
    enum OrderDirection: CustomStringConvertible {
        case asc
        case desc
        
        var description: String {
            switch self {
            case .asc:
                return ""
            case .desc:
                return "-"
            }
        }
    }
    
    enum DateInterval: CustomStringConvertible {
        case onGivenDayOnly
        case afterGivenDay
        case beforeGivenDay
        
        var description: String {
            switch self {
            case .onGivenDayOnly:
                return "="
            case .beforeGivenDay:
                return "<"
            case .afterGivenDay:
                return ">"
            }
        }
    }
    
    enum DateFilterType: CustomStringConvertible {
        case start
        case end
        
        var description: String {
            switch self {
            case .start:
                return "date_start"
            case .end:
                return "date_end"
            }
        }
    }
    
    struct DateFilter {
        var referenceDate: Date
        var dateInterval: DateInterval
        var isSet: Bool
        var filterType:DateFilterType
        
        init(_filterType: DateFilterType) {
            referenceDate = Date()
            dateInterval = .onGivenDayOnly
            isSet = false
            filterType = _filterType
        }
        
        func getDateFilterString()->String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: referenceDate)
            return isSet ? filterType.description + dateInterval.description + dateString : ""
        }
    }
    
    struct SortingParam {
        var by: OrderBy
        var direction: OrderDirection
        
        init() {
            by = .none
            direction = .asc
        }
    }
    
    var dataset: String
    var sort: SortingParam
    var start: Int
    var rows: Int
    var dateStartFilter: DateFilter
    var dateEndFilter: DateFilter
    
    init() {
        dataset = "evenements-a-paris"
        sort = SortingParam()
        start = 0
        rows = 10
        dateStartFilter = DateFilter(_filterType: .start)
        dateEndFilter = DateFilter(_filterType: .end)
    }
    
    // Update Sorting
    mutating func update(for _by:Int, _direction: Int){
        switch _by {
        case 0:
        sort.by = .dateStart
        case 1:
        sort.by = .dateEnd
        default:
        sort.by = .none
        }
        switch _direction {
        case 0:
        sort.direction = .asc
        case 1:
        sort.direction = .desc
        default:
        sort.direction = .asc
        }
    }
    
    // Update date filtering
    mutating func update(for _filterType: DateFilterType, with _dateInterval: DateInterval, at _date:Date){
        switch _filterType {
        case .start:
            dateStartFilter.isSet = true
            dateStartFilter.dateInterval = _dateInterval
            dateStartFilter.referenceDate = _date
        case .end:
            dateEndFilter.isSet = true
            dateEndFilter.dateInterval = _dateInterval
            dateEndFilter.referenceDate = _date
        }
    }
    
    // Update number of rows to get
    mutating func getMoreData(){
        start += 10
    }
    
    // Get date filter string for URL
    func getDateFiltersString() -> String {
        if dateStartFilter.isSet && dateEndFilter.isSet {
            return dateStartFilter.getDateFilterString() + " and " + dateEndFilter.getDateFilterString()
        }else{
            return dateStartFilter.getDateFilterString() + dateEndFilter.getDateFilterString()
        }
    }
    
    mutating func resetDateFilters() {
        dateStartFilter = DateFilter(_filterType: .start)
        dateEndFilter = DateFilter(_filterType: .end)
    }
}
