//
//  AudioFileModel.swift
//  ProjectDali
//
//  Created by William Robinson on 12/07/2015.
//  Copyright © 2015 William Robinson. All rights reserved.
//

import UIKit

class AudioFileModel: NSObject, NSCoding {

    var filePath = ""
    
    
    init(filePath: String) {
        self.filePath = filePath
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        
        self.filePath = (decoder.decodeObjectForKey("FilePath") as? String)!
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.filePath, forKey: "FilePath")
    }
}
