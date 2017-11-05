//
//  ViewController.swift
//  SimpleWeather
//
//  Created by Hendy Chua on 1/10/17.
//  Copyright © 2017 Hendy Chua. All rights reserved.
//

import UIKit
import CoreLocation

class WXController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {

    var backgroundImageView : UIImageView?
    var blurredImageView : UIImageView?
    var tableView : UITableView?
    var screenHeight : CGFloat?
    
    var temperatureLabel : UILabel?
    var cityLabel : UILabel?
    var conditionsLabel : UILabel?
    var iconView : UIImageView?
    var hiloLabel : UILabel?
    
    private let hourlyDateFormatter = DateFormatter()
    
    private(set) var currentLocation: CLLocation? {
        didSet {
            self.updateCurrentConditions()
            self.updateHourlyForecast()
        }
    }
    
    private(set) var hourlyConditions: [WXCondition]? {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    private let locationManager: CLLocationManager =  CLLocationManager()
    private let client: WXClient = WXClient()
    private var isFirstUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourlyDateFormatter.dateFormat = "h a"
        
        self.screenHeight = UIScreen.main.bounds.height
        
        let background = UIImage(named: "bg")
        self.backgroundImageView = UIImageView(image: background)
        self.view.addSubview(self.backgroundImageView!)
        
        self.blurredImageView = UIImageView()
        self.blurredImageView?.contentMode = .scaleAspectFill
        self.blurredImageView?.alpha = 0
        // can't blur it because of having issues with import LBBlurredImage library
        self.blurredImageView = UIImageView(image: background)
        self.view.addSubview(self.blurredImageView!)
        
        self.tableView = UITableView()
        self.tableView?.backgroundColor = .clear
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorColor = UIColor.white.withAlphaComponent(0.2)
        self.tableView?.isPagingEnabled = true
        self.view.addSubview(self.tableView!)
        
        let headerFrame = UIScreen.main.bounds
        let inset : CGFloat = 20
        let temperatureHeight : CGFloat = 110
        let hiloHeight : CGFloat = 40
        let iconHeight : CGFloat = 30
        
        let hiloFrame = CGRect(x: inset,
                               y: headerFrame.size.height - hiloHeight,
                               width: headerFrame.size.width - (2 * inset),
                               height: hiloHeight)
        
        let temperatureFrame = CGRect(x: inset,
                                      y: headerFrame.size.height - (temperatureHeight + hiloHeight),
                                      width: headerFrame.size.width - (2 * inset),
                                      height: temperatureHeight)
        
        let iconFrame = CGRect(x: inset,
                               y: temperatureFrame.origin.y - iconHeight,
                               width: iconHeight,
                               height: iconHeight)
        
        var conditionsFrame = iconFrame
        conditionsFrame.size.width = self.view!.bounds.size.width - (((2 * inset) + iconHeight) + 10)
        conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10)
        
        let header = UIView(frame: headerFrame)
        header.backgroundColor = .clear
        self.tableView?.tableHeaderView = header
        
        // bottom left
        self.temperatureLabel = UILabel(frame: temperatureFrame)
        self.temperatureLabel?.backgroundColor = .clear
        self.temperatureLabel?.textColor = .white
        self.temperatureLabel?.text = "0°"
        self.temperatureLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 120)
        header.addSubview(self.temperatureLabel!)
        
        // bottom left
        self.hiloLabel = UILabel(frame: hiloFrame)
        self.hiloLabel?.backgroundColor = .clear
        self.hiloLabel?.textColor = .white
        self.hiloLabel?.text = "0° / 0°"
        self.hiloLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 28)
        header.addSubview(self.hiloLabel!)
        
        // top
        self.cityLabel = UILabel(frame: CGRect(x: 0, y: 20, width: self.view!.bounds.size.width, height: 30))
        self.cityLabel?.backgroundColor = .clear
        self.cityLabel?.textColor = .white
        self.cityLabel?.text = "Loading..."
        self.cityLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)
        self.cityLabel?.textAlignment = .center
        header.addSubview(self.cityLabel!)
        
        self.conditionsLabel = UILabel(frame: conditionsFrame)
        self.conditionsLabel?.backgroundColor = .clear
        self.conditionsLabel?.textColor = .white
        self.conditionsLabel?.text = "Clear"
        self.conditionsLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 18)
        header.addSubview(self.conditionsLabel!)
        
        // bottom left
        self.iconView = UIImageView(frame: iconFrame)
        self.iconView?.image = UIImage(named: "weather-clear")
        self.iconView?.contentMode = .scaleAspectFit
        self.iconView?.backgroundColor = .clear
        header.addSubview(self.iconView!)
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.findCurrentLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let bounds = self.view!.bounds
        
        self.backgroundImageView?.frame = bounds
        self.blurredImageView?.frame = bounds
        self.tableView?.frame = bounds
    }
    
    // UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let hourlyConditions = self.hourlyConditions {
            return hourlyConditions.count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        
        cell!.selectionStyle = .none
        cell!.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        cell!.textLabel?.textColor = UIColor.white
        cell!.detailTextLabel?.textColor = UIColor.white
        
        if indexPath.row == 0 {
            cell!.textLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
            cell!.textLabel!.text = "Hourly Forecast"
            cell!.detailTextLabel!.text = ""
            cell!.imageView!.image = nil
        } else {
            let weather = hourlyConditions?[indexPath.row - 1]
            cell!.textLabel!.font = UIFont(name:"HelveticaNeue-Light", size:18)
            cell!.detailTextLabel!.font = UIFont(name:"HelveticaNeue-Medium", size:18)
            cell!.textLabel!.text = self.hourlyDateFormatter.string(from: weather!.date!)
            cell!.detailTextLabel!.text = String(format:"%.0f°", weather!.temperature!)
            cell!.imageView!.image = UIImage(named: weather!.imageName())
            cell!.imageView!.contentMode = .scaleAspectFit
        }
        
        return cell!
        
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.screenHeight! / CGFloat(self.tableView(tableView, numberOfRowsInSection: indexPath.section))
    }
    
    // UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.bounds.size.height
        let position = max(scrollView.contentOffset.y, 0.0)
        let percent = min(position / height, 1.0)
//        print("\(percent)")
        self.blurredImageView?.alpha = percent
    }
    
    func findCurrentLocation() {
        self.isFirstUpdate = true
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // ignore the first update because it is almost always cached
        if self.isFirstUpdate {
            self.isFirstUpdate = false
            return
        }
        
        let location = locations.last!
        
        if location.horizontalAccuracy > 0 {
            self.currentLocation = location
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func updateCurrentConditions() {
        self.client.fetchCurrentConditionsForLocation(location: currentLocation!.coordinate, completion: { [unowned self]  wxCondition in
//            print("\(wxCondition)")
            if let wxCondition = wxCondition {
                self.temperatureLabel?.text = String(format: "%.0f°", wxCondition.temperature!)
                self.conditionsLabel?.text = wxCondition.condition?.capitalized
                self.cityLabel?.text = wxCondition.locationName?.capitalized
                self.iconView?.image = UIImage(imageLiteralResourceName: wxCondition.imageName())
                self.hiloLabel?.text = String(format: "%.0f° / %.0f°", arguments: [wxCondition.tempHigh!, wxCondition.tempLow!])
            }
        })
    }
    
    func updateHourlyForecast() {
        self.client.fetchHourlyForecastForLocation(location: currentLocation!.coordinate, completion: { [unowned self]
            wxConditions in
//            print("\(wxConditions)")
            self.hourlyConditions = wxConditions
        })
    }
}

