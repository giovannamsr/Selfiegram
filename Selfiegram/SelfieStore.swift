//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Giovanna Rodrigues on 21/07/21.
//

import Foundation
import UIKit.UIImage

class Selfie : Codable
{
    let created : Date
    let id : UUID
    var title : String = "New Selfie!"
    var image : UIImage?
    {
        get
        {
            return SelfieStore.shared.getImage(id = self.id)
        }
        set
        {
            try? SelfieStore.shared.setImage(id = self.id, image = newValue)
        }
    }
    init(title:String)
    {
        self.title = title
        self.created = Date()
        self.id = UUID()
    }

}

enum SelfieStoreError : Error
{
    case cannotSaveImage(UIImage?)
}

final class SelfieStore
{
    static let shared = SelfieStore()
    private var imageCache : [UUID:UIImage] = [:]
    var documentsFolder : URL
    {
        return FileManager.default.urls(for: .documentDirectory, in: allDomainsMask).first!
    }
    
    /// Gets an image by ID. Will be cached in memory for future lookups.
    /// - parameter id: the id of the selfie whose image you are after
    /// - returns: the image for that selfie or nil if it doesn't exist
    func getImage(id:UUID) -> UIImage?
    {
        //if image is already in cache, return it
        if let image = imageCache[id]
        {
            return image
        }
        
        //if image is not in cache
        let imageURL = documentsFolder.appendingPathComponent("\(id.uuidString)-image.jpg")
        
        //get data from file
        guard let imageData = try? Data(contentsOf: imageURL) else
        {
            return nil
        }
        
        //get image from data
        guard let image = UIImage(data: imageData) else
        {
            return nil
        }
        
        //store in cache
        imageCache[id] = image
        
        return image
        
    }
    
    /// Saves an image to disk.
    /// - parameter id: the id of the selfie you want this image associated with
    /// - parameter image: the image you want saved
    /// - Throws: `SelfieStoreObject` if it fails to save to disk
    func setImage(id:UUID, image:UIImage?) throws
    {
        let fileName = "\(id.uuidString)-image.jpg"
        let destinationURL = self.documentsFolder.appendingPathComponent(fileName)
        
        if let image = image
        {
            //try to convert the image to jpeg
            guard let data = UIImageJPEGRepresentation(image, 0.9) else
            {
                throw SelfieStoreError.cannotSaveImage(image)
            }
            try data.write(to: destinationURL)
        }
        //if image is nil, remove
        else
        {
            try FileManager.default.removeItem(at: destinationURL)
        }
        //cache this image in memory
        imageCache[id] = image
    }
    
    /// Returns a list of Selfie objects loaded from disk.
    /// - returns: an array of all selfies previously saved
    /// - Throws: `SelfieStoreError` if it fails to load a selfie correctly from disk
    func listSelfies() throws -> [Selfie]
    {
        let contents = try FileManager.default.contentsOfDirectory(at: self.documentsFolder, includingPropertiesForKeys: nil)
        // Get all files whose path extension is 'json', load them as data, and decode them from JSON
        return try contents.filter { $0.pathExtension == "json" }
            .map { try Data(contentsOf: $0) }
            .map { try JSONDecoder().decode(Selfie.self, from: $0) }
    }
    
    /// Deletes a selfie, and its corresponding image, from disk.
    /// This function simply takes the ID from the Selfie you pass in, and gives it to the other version of the delete function.
    /// - parameter selfie: the selfie you want deleted
    /// - Throws: `SelfieStoreError` if it fails to delete the selfie from disk
    func delete(selfie:Selfie) throws
    {
        try delete(id: selfie.id)
        //throw SelfieStoreError.cannotSaveImage(nil)
    }
    
    /// Deletes a selfie, and its corresponding image, from disk.
    /// - parameter id: the id property of the Selfie you want deleted
    /// - Throws: `SelfieStoreError` if it fails to delete the selfie from disk
    func delete(id:UUID) throws
    {
        let selfieDataFileName = "\(id.uuidString).json"
        let imageFileName = "\(id.uuidString)-image.jpg"
        let selfieDataURL = self.documentsFolder.appendingPathComponent(selfieDataFileName)
        let imageURL = self.documentsFolder.appendingPathComponent(imageFileName)
        
        //remove files if they exist
        if FileManager.default.fileExists(atPath: selfieDataURL.path)
        {
            try FileManager.default.removeItem(at: selfieDataURL)
        }
        if FileManager.default.fileExists(atPath: imageURL.path)
        {
            try FileManager.default.removeItem(at: imageURL)
        }
        //remove image from cache
        imageCache[id] = nil
    }
    //load the selfie that matches the id from disk
    func load(id:UUID) -> Selfie?
    {
        return nil
    }
    //save the passed in selfie to disk
    func save(selfie:Selfie) throws
    {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
}
