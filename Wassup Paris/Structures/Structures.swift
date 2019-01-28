//
//  EventStruct.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/28/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import Foundation

struct EventsDataset: Codable{
    let nhits: Int
    let parameters: DatasetParam
    let records: [Event]
}

struct DatasetParam: Codable {
    let timezone: String
    let rows: Int
}

struct Event: Codable {
    let datasetid: String
    let recordid: String
}
