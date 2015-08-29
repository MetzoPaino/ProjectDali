//
//  DataModel.swift
//  ProjectDali
//
//  Created by William Robinson on 12/07/2015.
//  Copyright © 2015 William Robinson. All rights reserved.
//

import UIKit

class DataModel: NSObject {

    var audioFilePaths = [AudioFileModel]()
    var audioFiles = [NSData]()
    
    override init() {
        super.init()
        loadData()
    }
    
    func saveData() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(audioFilePaths, forKey: "ProjectDaliDataModelAudioFilePaths")
        archiver.encodeObject(audioFiles, forKey: "ProjectDaliDataModelAudioFiles")

        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadData() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                audioFilePaths = (unarchiver.decodeObjectForKey("ProjectDaliDataModelAudioFilePaths") as? [AudioFileModel])!
                audioFiles = (unarchiver.decodeObjectForKey("ProjectDaliDataModelAudioFiles") as? [NSData])!

                unarchiver.finishDecoding()
            }
        }
    }
    
    func dataFilePath() -> String {
        
        let url = NSURL(fileURLWithPath: documentsDirectory())
        url.URLByAppendingPathComponent("ProjectDali.plist")

        return url.path!
//        return documentsDirectory().stringByAppendingPathComponent("ProjectDali.plist")
    }
    
    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }
}
