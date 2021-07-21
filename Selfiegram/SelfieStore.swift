//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Marcelo Rodrigues de Sousa on 21/07/21.
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
    
    //return the image associated with a particular selfie's id or nil
    func getImage(id:UUID) -> UIImage?
    {
        return nil
    }
    //save the image to disk using the id passed in to associate it back with a selfie
    func setImage(id:UUID, image:UIImage?) throws
    {
        throw SelfieStoreError.cannotSaveImage(image)
    }
    //return an array with every selfie in the store
    func listSelfies() throws -> [Selfie]
    {
        return []
    }
    //delete the selfie and its associated image by calling the other delete function
    func delete(selfie:Selfie) throws
    {
        throw SelfieStoreError.cannotSaveImage(nil)
    }
    //delete the selfie and its associated image that matches the id parameter
    func delete(id:UUID) throws
    {
        throw SelfieStoreError.cannotSaveImage(nil)
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
