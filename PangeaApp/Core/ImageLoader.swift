//
//  ImageLoader.swift
//  PangeaApp
//
//  Created by Larisa Clemenceau on 18/08/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    
    private let cache = NSCache<NSURL, UIImage>()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    private init() {}
    
    @discardableResult
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> UUID? {
        // 1. Cache
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return nil
        }
        
        // 2. Network
        let uuid = UUID()
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            defer { self?.runningRequests.removeValue(forKey: uuid) }
            
            var image: UIImage?
            if let data = data {
                image = UIImage(data: data)
            }
            
            if let img = image {
                self?.cache.setObject(img, forKey: url as NSURL)
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
        
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
