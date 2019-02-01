//
//  Protocols.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/30/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import Foundation

protocol AnimatedCellNavigationDelegate {
    func willGoBack()
}

protocol GetMoreDataDelegate {
    func getMoreData()
}

protocol DateCallbackDelegate {
    func setDate(for _tag: Int, at _date: Date)
    func resetDate()
}
