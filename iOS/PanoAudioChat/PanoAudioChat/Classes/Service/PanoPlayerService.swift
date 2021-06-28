//
//  PanoPlayerManager.swift
//  PanoAudioChat
//
//  Created by wenhua.zhang on 2020/11/3.
//

import UIKit

struct PanoAudioModel {
    
    var audioName: String!
    
    var isPause: Bool = false
}

class PanoPlayerService : PanoBaseService {
    
    let audioNames = ["音乐1", "音乐2" , "音乐3"];
    
    let soundNames = ["哈哈哈", "哇哦" , "鼓掌" ,"尴尬", "乌鸦" , "起哄"];
    
    var activeAudios = [String]();
    
    var activeAudioName = "";
    
    var activeAudioIsPaused = false
 
    override class func service() -> PanoPlayerService? {
        return PanoServiceManager.service(type: .player) as? PanoPlayerService
    }
    
    func loadMusicResouces() {
    
        activeAudios.append(contentsOf: audioNames)
        
        activeAudios.append(contentsOf: soundNames)
        print("loadMusicResouces begin", self , CFAbsoluteTimeGetCurrent())
        for index in 0..<audioNames.count {
            let name = activeAudios[index]
            guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
                continue
            }
            let result = PanoClientService.rtcEngineKit()?.createAudioMixingTask(Int64(index), filename: path)
            print("createAudioMixingTask \(String(describing: result?.rawValue))")
        }
        for index in 0..<soundNames.count {
            let name = soundNames[index]
            guard let path = Bundle.main.path(forResource: name, ofType: "caf") else {
                continue
            }
            let taskId = index + audioNames.count;
            _ = PanoClientService.rtcEngineKit()?.createAudioMixingTask(Int64(taskId), filename: path)
        }
        print("loadMusicResouces end", CFAbsoluteTimeGetCurrent())
    }
    
    func unLoadMusicResouces() {
        for index in 0..<activeAudios.count {
            PanoClientService.rtcEngineKit()?.destroyAudioMixingTask(Int64(index))
        }
    }
    
    func startSoundEffectTask(fileName: String, volume: Int32) {
        let taskId = activeAudios.firstIndex { (name) -> Bool in
            return fileName == name
        }
        if let id = taskId {
            let config = PanoRtcAudioMixingConfig()
            config.publishVolume = volume
            config.loopbackVolume = volume
            config.enableLoopback = true
            PanoClientService.rtcEngineKit()?.startAudioMixingTask(Int64(id), with: config)
        }
    }
    
    func stopSoundEffectTask(fileName: String) {
        let taskId = activeAudios.firstIndex { (name) -> Bool in
            return fileName == name
        }
        if let id = taskId {
            let result = PanoClientService.rtcEngineKit()?.stopAudioMixingTask(Int64(id))
            print("stopAudioMixingTask  \(String(describing: result?.rawValue))")
        }
    }
    
     func startAudioMixingTask(fileName: String, volume: Int32) {
        let taskId = activeAudios.firstIndex { (name) -> Bool in
            return fileName == name
        }
        if let id = taskId {
            self.stopAudioMixingTask(fileName: activeAudioName)
            activeAudioName = fileName
            let config = PanoRtcAudioMixingConfig()
            config.publishVolume = volume
            config.loopbackVolume = volume
            config.enableLoopback = true
            config.cycle = 0
            activeAudioIsPaused = false
            PanoClientService.rtcEngineKit()?.startAudioMixingTask(Int64(id), with: config)
        }
    }
    
    func updateAudioMixingTask(fileName: String, volume: Int32) {
        let taskId = activeAudios.firstIndex { (name) -> Bool in
            return fileName == name
        }
        if let id = taskId {
            let config = PanoRtcAudioMixingConfig()
            config.publishVolume = volume
            config.loopbackVolume = volume
            config.enableLoopback = true
            config.cycle = 0
            PanoClientService.rtcEngineKit()?.updateAudioMixingTask(Int64(id), with: config)
        }
    }

    func stopAudioMixingTask(fileName: String) {
        let taskId = activeAudios.firstIndex { (name) -> Bool in
            return fileName == name
        }
        if let id = taskId {
            let result = PanoClientService.rtcEngineKit()?.stopAudioMixingTask(Int64(id))
            print("stopAudioMixingTask  \(String(describing: result?.rawValue))")
            activeAudioName = ""
        }
    }
    
    func resumeAudioMixing(fileName: String) {
        let taskId = activeAudios.firstIndex { (name) -> Bool in
            return fileName == name
        }
        if let id = taskId {
            activeAudioIsPaused = false
            PanoClientService.rtcEngineKit()?.resumeAudioMixing(Int64(id))
        }
    }

     func pauseAudioMixing(fileName: String) {
        let taskId = activeAudios.firstIndex { (name) -> Bool in
            return fileName == name
        }
        if let id = taskId {
            activeAudioIsPaused = true
            PanoClientService.rtcEngineKit()?.pauseAudioMixing(Int64(id))
        }
    }
    
    
}


extension PanoPlayerService {
    
    func updateVolume(volume: Int32){
        if  activeAudioIsPaused {
            return
        }
        if activeAudioName.isEmpty {
            return
        }
        
        self.updateAudioMixingTask(fileName: activeAudioName, volume: volume)
    }
    
    func chooseNextAction() {
        let taskId = audioNames.firstIndex { (name) -> Bool in
            return activeAudioName == name
        }
        if let id = taskId {
            let nextAudio = (id + 1) % audioNames.count
            self.startAudioMixingTask(fileName: audioNames[nextAudio], volume: 100)
        } else {
            self.startAudioMixingTask(fileName: audioNames.first ?? "", volume: 100)
        }
    }
    
    func startPlayAction(pause: Bool) {
        if isMusicPlaying() {
            if pause {
                self.pauseAudioMixing(fileName: activeAudioName)
            } else {
                self.resumeAudioMixing(fileName: activeAudioName)
            }
        } else {
            self.startAudioMixingTask(fileName: audioNames.first ?? "", volume: 100)
        }
    }
    
    func isMusicPlaying() -> Bool {
        let taskId = audioNames.firstIndex { (name) -> Bool in
            return activeAudioName == name
        }
        return taskId != nil
    }
}
