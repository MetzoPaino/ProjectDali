//
//  ViewController.swift
//  ProjectDali
//
//  Created by William Robinson on 27/06/2015.
//  Copyright © 2015 William Robinson. All rights reserved.
//

import UIKit
import WatchConnectivity
import AVFoundation

class ViewController: UIViewController, WCSessionDelegate {

    @IBOutlet var label: UILabel!
//    var appDelegate = UIApplication.sharedApplication().delegate
//    var dataModel = appDelegate.dataModel
    
//    var session: WCSession?
    var session: WCSession!
    var dataModel: DataModel!
    var myPlayer = AVAudioPlayer()

    
    
    
    
//    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
//    init() {
////        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        super.init()
//    }

//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("!!!!!!!")
        
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self;
            session.activateSession()
        }
        print("session \(session)")
        
//        NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
        
//        self.session = appDelegate.session
//        session?.delegate = self
//        var appDelegate = UIApplication.sharedApplication().delegate
        
//        AppDelegate appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//        session = appDelegate.session
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    func prepareYourSound(myData:NSData) {
//        
//        myPlayer = AVAudioPlayer(data: self.dataModel.audioFiles.first)
//        myPlayer.prepareToPlay()
//    }


    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        print("file \(file)")
        
        let audioFilePath = AudioFileModel(filePath: file.fileURL.relativePath!)
        dataModel.audioFilePaths.append(audioFilePath)
        

        var getImagePath = file.fileURL.path!
        
        var checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(getImagePath))
        {
            let data = NSData(contentsOfFile: getImagePath)

            print("FILE AVAILABLE");
            
            
            dataModel.audioFiles.append(data!)

        }
        else
        {
            print("FILE NOT AVAILABLE");
        }

        
//        var fileManager = NSFileManager.defaultManager()
//        var bundle : NSString = NSBundle.mainBundle().pathForResource("ProjectDali", ofType: "plist")!
//        fileManager.copyItemAtPath(bundle, toPath: audioFilePath,
//        fileManager.copyItemAtPath(<#T##srcPath: String##String#>, toPath: <#T##String#>)
        


        
        
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            print("got it")
            
            let value = applicationContext["Value"] as? Int
            
            if value != nil {
                self.label.text = "\(value)"
            }
        }
    }
    @IBAction func refreshList(sender: AnyObject) {
        
        do {
            try myPlayer = AVAudioPlayer(data: self.dataModel.audioFiles.first!)
            myPlayer.play()
        } catch {
            //Handle the error
            print("errorororor")
        }
    }
        //        myPlayer = AVAudioPlayer(data: self.dataModel.audioFiles.first)
        //        myPlayer.prepareToPlay()
        
        
//        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
//        
//        let audioPathModel = self.dataModel.audioFilePaths.first
//        
//        if let audioPath = audioPathModel {
//            
//            var getImagePath = paths.stringByAppendingPathComponent(audioPath.filePath)
//            
//            var checkValidation = NSFileManager.defaultManager()
//            
//            if (checkValidation.fileExistsAtPath(getImagePath))
//            {
//                print("FILE AVAILABLE");
//            }
//            else
//            {
//                print("FILE NOT AVAILABLE");
//            }
//        }
        

        
//        NSString *path;
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SomeDirectory"];
//        path = [path stringByAppendingPathComponent:@"SomeFileName"];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
//        {
   // }
}

