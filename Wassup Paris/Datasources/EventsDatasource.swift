//
//  EventsDatasource.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/28/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import UIKit

class EventsDatasource: NSObject {
    var eventList: [EventsDataset.Event]
    var urlParam: UrlParamManager
    
    var delegate: GetMoreDataDelegate?
    
    override init() {
        eventList = []
        urlParam = UrlParamManager()
    }
    
    func getEvents(_atInit: Bool, completion: ((Result<EventsDataset>) -> Void)?){
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "opendata.paris.fr"
        urlComponents.path = "/api/records/1.0/search/"
        urlComponents.queryItems = getQueryItems(_atInit: _atInit)
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            DispatchQueue.main.async {
                if let error = responseError {
                    completion?(.failure(error))
                } else if let jsonData = responseData {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyymmdd)
                    
                    do {
                        let eventsDataset = try decoder.decode(EventsDataset.self, from: jsonData)
                        if _atInit { self.eventList.removeAll() }
                        for event in eventsDataset.records {
                            self.eventList.append(event)
                        }
                        completion?(.success(eventsDataset))
                    } catch {
                        completion?(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                    completion?(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func getQueryItems(_atInit: Bool)-> [URLQueryItem]{
        var queryItemsArray: [URLQueryItem] = []
        
        urlParam.start = _atInit ? 0 : urlParam.start
        
        // filling up the url parameters' array
        queryItemsArray.append(URLQueryItem(name: "dataset", value: urlParam.dataset))
        queryItemsArray.append(URLQueryItem(name: "rows", value: String(urlParam.rows)))
        queryItemsArray.append(URLQueryItem(name: "sort", value: String(urlParam.sort.direction.description) + String(urlParam.sort.by.description)))
        queryItemsArray.append(URLQueryItem(name: "start", value: String(urlParam.start)))
        queryItemsArray.append(URLQueryItem(name: "q", value: String(urlParam.getDateFiltersString())))
        
        
        return queryItemsArray
    }
    
    func updateParam(for _by:Int, _direction: Int){
        urlParam.update(for: _by, _direction: _direction)
    }
    
    func updateParam(for _dateFilterType: UrlParamManager.DateFilterType, with _dateInterval: UrlParamManager.DateInterval, at _date: Date){
        urlParam.update(for: _dateFilterType, with: _dateInterval, at: _date)
    }
    
    func resetDateFilters(){
        urlParam.resetDateFilters()
    }
    
    func getMoreData(){
        urlParam.getMoreData()
    }
}

extension EventsDatasource: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCellNib") as! EventCell
        let event = eventList[indexPath.row]
        
        cell.event = event
        
        // Triggered requesting data function when you DID reach the table view's bottom
        if indexPath.row == eventList.count - 1 {
            if let _ = delegate {
                delegate?.getMoreData()
            }
        }
        
        return cell
    }
    
}
