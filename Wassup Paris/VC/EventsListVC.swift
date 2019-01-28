//
//  EventsListVC.swift
//  Wassup Paris
//
//  Created by Martin Bricard on 1/28/19.
//  Copyright © 2019 braminstudio. All rights reserved.
//

import UIKit

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

class EventsListVC: UIViewController {

    @IBOutlet weak var DateFilterLabel: UILabel!
    @IBOutlet weak var FiltersLabel: UILabel!
    @IBOutlet weak var EventsTableView: UITableView!
    
    var eventsDatasource: EventsDatasource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsDatasource = EventsDatasource()
        EventsTableView.dataSource = eventsDatasource
        EventsTableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "EventCellNib")
        
        let urlParams = ["dataset":"evenements-a-paris"]
        
        getEvents(for: urlParams){ (result) in
            switch result {
            case .success(let eventsDataset):
                self.eventsDatasource!.fillUp(with: eventsDataset.records)
                self.EventsTableView.reloadData()
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    
    func getEvents(for queryItems:[String:String], completion: ((Result<EventsDataset>) -> Void)?){
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "opendata.paris.fr"
        urlComponents.path = "/api/records/1.0/search/"
        
        urlComponents.queryItems = []
        
        for queryItem in queryItems{
            let datasetItem = URLQueryItem(name: queryItem.key, value: queryItem.value)
            urlComponents.queryItems?.append(datasetItem)
        }
        
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
                    // Now we have jsonData, Data representation of the JSON returned to us
                    // from our URLRequest...
                    print(jsonData)
                    // Create an instance of JSONDecoder to decode the JSON data to our
                    // Codable struct
                    let decoder = JSONDecoder()
                    
                    do {
                        // We would use Post.self for JSON representing a single Post
                        // object, and [Post].self for JSON representing an array of
                        // Post objects
                        let eventsDataset = try decoder.decode(EventsDataset.self, from: jsonData)
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
    
    @IBAction func onEditDateFilterButtonClick(_ sender: Any) {
    }
    
    @IBAction func onEditFiltersButtonClick(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
