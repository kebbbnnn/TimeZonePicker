//
//  File.swift
//  
//
//  Created by Kevin Ladan on 5/9/24.
//

import Foundation
import CoreLocation

public enum TimeZones {
    static var timeZones: [TimeZoneLocation] = []
    
    @discardableResult
    public static func preload() throws -> [TimeZoneLocation] {
        return try self.load()
    }
    
    public static func load() throws -> [TimeZoneLocation] {
        var timeZones = self.timeZones
        
        if timeZones.isEmpty {
            let bundle = Bundle.module
            let path = bundle.path(forResource: "all_cities_adj", ofType: "plist")!

            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)

            let decoder = PropertyListDecoder()

            timeZones = try decoder.decode([TimeZoneLocation].self, from: data)
            
            self.timeZones = timeZones
        }
        
        return timeZones
    }
    
    private static func timeZone(from tz: TimeZone) -> TimeZoneLocation? {
        return self.timeZones.first {
            return $0.timeZoneName.lowercased() == tz.identifier.lowercased()
        }
    }
}

extension TimeZones {
    public static func getTimeZone(location: CLLocationCoordinate2D, completion: @escaping ((TimeZoneLocation) -> Void)) {
        let cllLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(cllLocation) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let placemarks = placemarks, let placemark = placemarks.first, let optTime = placemark.timeZone {
                    if let city = placemark.locality {
                        let tmp = self.timeZones.first {
                            return $0.city.lowercased() == city.lowercased()
                        }
                        if let tmp {
                            completion(tmp)
                        } else if let tz = self.timeZone(from: optTime) {
                            completion(tz)
                        }
                    } else if let tz = self.timeZone(from: optTime) {
                        completion(tz)
                    }
                }
            }
        }
    }
}
