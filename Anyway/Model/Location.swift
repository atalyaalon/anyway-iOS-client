//
//  Location.swift
//  Fame
//
//  Created by Aviel Gross on 5/20/15.
//  Copyright (c) 2015 Globalbit. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

//struct Coordinate {
//    var lat: String
//    var lng: String
//    
//    init(lat: String, lng: String) {
//        self.lat = lat
//        self.lng = lng
//    }
//    
//    init(_ coord: CLLocationCoordinate2D) {
//        self.lat = "\(coord.latitude)"
//        self.lng = "\(coord.longitude)"
//    }
//}

public extension Notification.Name {
    public static var locationServicesDenied = Notification.Name("locationServicesDenied")
    public static var locationServicesRestricted = Notification.Name("locationServicesRestricted")
    public static var knownLocationChanged = Notification.Name("knownLocationChanged")
}

public extension CLLocation {
    public var asData: Data { return NSKeyedArchiver.archivedData(withRootObject: self) }
    public class func from(_ data: Data) -> CLLocation? { return data.unarchived as? CLLocation ?? nil }
}

public extension CLPlacemark {
    public var asData: Data { return NSKeyedArchiver.archivedData(withRootObject: self) }
    public class func from(_ data: Data) -> CLPlacemark? { return data.unarchived as? CLPlacemark ?? nil }
}

public class Location: NSObject, CLLocationManagerDelegate {
    
    public static var shared = Location()
    
    let maxDeltaForLastLocation: Seconds = 5
    
    var lastKnownLocation: CLLocation? {
        set{
            guard let location = newValue else { return }
            UserDefaults.standard.set(location.asData, forKey: "lastKnownLocation")
            NotificationCenter.default.post(name: .knownLocationChanged, object: nil)
        }
        get{
            return man.location ??
                UserDefaults.standard.data(forKey: "lastKnownLocation").flatMap(CLLocation.from)
        }
    }
    
    func recentLocation(maxSecondsFromNow maxSec: Seconds) -> CLLocation? {
        if let loc = lastKnownLocation , loc.timestamp.timeIntervalSinceNow < maxSec {
            return loc
        }
        return nil
    }
    
    fileprivate var man = CLLocationManager()
    
    //MARK: - Logic
    
    var isLocationMonitoringAuthorized: Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }
    
    var didAskAuthorization: Bool {
        return CLLocationManager.authorizationStatus() != .notDetermined
    }
    
    public func requestWhenInUseLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.notDetermined {
            print("🌎 Requesting WhenInUse location updates...")
            man.delegate = nil //we just don't care
            man.requestWhenInUseAuthorization()
        }
    }
    
    func beginTrackingLocation(requestAuthorizationIfNeeded shouldRequest: Bool) {
        man.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.notDetermined {
            //NEVER ASKED
            if shouldRequest {
                let sel = #selector(CLLocationManager.requestAlwaysAuthorization)
                if man.responds(to: sel) {
                    man.requestAlwaysAuthorization()
                } else {
                    beginUpdateLocations()
                }
                
            } else {
                //not requesting...
            }
        }
        else if status == .authorizedAlways || status == .authorizedWhenInUse {
            //GRANTED
            beginUpdateLocations()
            
        } else if status == .restricted {
            //RESTRICTED
            presentLocationsRestrictedAlert()
            
        } else if status == .denied {
            //DENIED
            presentLocationsDeniedAlert()
        }
    }
    
    func stopTrackingLocations() {
        man.stopMonitoringSignificantLocationChanges()
    }
    
    func beginUpdateLocations() {
        print("🌎 Tracking location...")
        man.delegate = self
        man.startMonitoringSignificantLocationChanges()
        //man.startUpdatingLocation()
    }
    
    var realm: Realm?
    
    func updateHistory(_ loc: CLLocation) {
        print("🌎 updateHistory: \(loc)")
        log(loc)
        
        // find edges for area to search accidents
        let areaDiameter = 70 // in meters
        
        let center = loc.coordinate
        
        let d = Double(areaDiameter) / 2 // meters from center to each edge
        let r_earth = 6378.0 * 1000.0 // earth eprox radius
        let pi = Double.pi
        let neY = center.latitude + (d / r_earth) * (180.0 / pi)
        let neX = center.longitude + (d / r_earth) * (180.0 / pi) / cos(center.latitude * pi/180.0)
        let ne = Coordinate(latitude: neY, longitude: neX)
        
        let swY = center.latitude - (d / r_earth) * (180.0 / pi)
        let swX = center.longitude - (d / r_earth) * (180.0 / pi) / cos(center.latitude * pi/180.0)
        let sw = Coordinate(latitude: swY, longitude: swX)
        
        let edges = (ne: ne, sw: sw)
        
        // get accidents in area, save event with accidents
        Network().getAnnotations(edges, filter: Filter()) { [weak self] annotations, totalCount in
            guard totalCount > 0 else { return }
            
            CLGeocoder().reverseGeocodeLocation(loc, completionHandler: { placemark, error in
                guard let place = placemark?.first else { return }
                
                do {
                    self?.realm = try Realm()
                    try self?.realm?.write {
                        let event = HistoryPosition()
                        for anot in annotations {
                            if let group = anot as? MarkerGroup {
                                event.markers.append(objectsIn: group.markers)
                            } else if let marker = anot as? Marker {
                                event.markers.append(marker)
                            }
                        }
                        event.locationPLacemark = place.asData
                        event.locationData = loc.asData
                        self?.realm?.add(event)
                    }
                } catch {
                    print("Realm error: \(error)")
                }
                
                
            })
            
        }
        
        
    }
    
    //MARK: - Alerts
    
    func presentLocationsRestrictedAlert() {
        NotificationCenter.default.post(name: .locationServicesRestricted, object: nil)
    }
    
    func presentLocationsDeniedAlert() {
        NotificationCenter.default.post(name: .locationServicesDenied, object: nil)
    }
    
    //MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        beginTrackingLocation(requestAuthorizationIfNeeded: false)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.first {
            print("🌎 locationManager: UpdatedLocation: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
            lastKnownLocation = loc
            self.updateHistory(loc)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("🌎 locationManager: DidFailWithError: \(error)")
        log(error: error as NSError?)
    }
    
    //MARK: - Debug Actions
    
    func log(_ loc: CLLocation) {
        let desc = "\(loc.timestamp.shortDescription) :: \(loc.coordinate.latitude), \(loc.coordinate.longitude)"
        logString(desc)
    }
    
    func log(error: NSError!) {
        let desc = error.description
        print(desc)
    }
    
    func logString(_ str: String) {
        if let locs = Defaults["locations"].string {
            Defaults["locations"] = "\(locs)\n\(str)"
        } else {
            Defaults["locations"] = str
        }
    }
}
