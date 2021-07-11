//
//  FlickrPhotoURLBuilder.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 10/07/21.
//

import Foundation
import CoreData

final class FlickrPhotoUrlBuilder {
    
    static func buildUrl(of photo: Photo) -> String {
        String(format:"https://live.staticflickr.com/%@/%@_%@_c.jpg",
               photo.server ?? "",
               photo.id ?? "",
               photo.secret ?? "")
    }
}
