//
//  PanoAudioService.swift
//  PanoAudioRoom
//
//  Created by wenhua.zhang on 2020/10/28.
//

import Foundation
import AVFoundation


let PanoAudioDumpFileName = "pano_audio.dump";

let PanoMaxAudioDumpFileSize: Int64 = 200 * 1024 * 1024;

protocol PanoAudioInterface {
    
    func unmuteAudio();
    
    func muteAudio();
    
    func startAudio(mute: Bool);
    
    func startAudio();
    
    func stopAudio();
    
    func startAudioDump(timeinterval: TimeInterval);
    
    func stopAudioDump();
}

protocol PanoAudioMixingInterface {
    
    func createAudioMixingTask(fileName: String);
    
    func destroyAudioMixingTask(fileName: String);
    
    func destroyAllAudioMixingTask()
    
    
}

class PanoAudioService : PanoBaseService  {
    
    override class func service() -> PanoAudioService? {
        return PanoServiceManager.service(type: .audio) as? PanoAudioService
    }
    
    var isMuted = false
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
}


extension PanoAudioService: PanoAudioInterface {

    func muteAudio() {
        isMuted = true
        let result = PanoClientService.rtcEngineKit()?.muteAudio()
        print("muteAudio \(String(describing: result))")
        PanoUserService.service()?.onUserAudioMute(PanoClientService.service().userId)
    }
    
    func unmuteAudio() {
        isMuted = false
        let result = PanoClientService.rtcEngineKit()?.unmuteAudio()
        print("stopAudio \(String(describing: result))")
        PanoUserService.service()?.onUserAudioUnmute(PanoClientService.service().userId)
    }
    
    func toggleAudio() {
        isMuted ? unmuteAudio() : muteAudio()
    }
    
    func startAudio(mute: Bool) {
        startAudio()
        if mute {
            self.muteAudio()
        }
    }
    
    func startAudio() {
        let result = PanoClientService.rtcEngineKit()?.startAudio()
        print("startAudio \(String(describing: result))")
        PanoUserService.service()?.onUserAudioStart(PanoClientService.service().userId)
    }
    
    func stopAudio() {
        let result = PanoClientService.rtcEngineKit()?.stopAudio()
        print("stopAudio \(String(describing: result))")
        PanoUserService.service()?.onUserAudioStop(PanoClientService.service().userId)
    }
    
    func isEnabledLoudspeaker() -> Bool {
        if let engint = PanoClientService.rtcEngineKit() {
            return engint.isEnabledLoudspeaker()
        }
        return false
    }
    
    func setLoudspeakerStatus(staus: Bool) {
        PanoClientService.rtcEngineKit()?.setLoudspeakerStatus(staus)
    }
    
    func startAudioDump(timeinterval: TimeInterval = -1) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let PanoAudioDumpFile = NSTemporaryDirectory() + PanoAudioDumpFileName
        PanoClientService.rtcEngineKit()?.startAudioDump(withFilePath: PanoAudioDumpFile, maxFileSize: PanoMaxAudioDumpFileSize)
        if timeinterval > 0 {
            self.perform(#selector(stopAudioDump), with: nil, afterDelay: timeinterval)
        }
    }
    
    @objc func stopAudioDump() {
        PanoClientService.rtcEngineKit()?.stopAudioDump()
    }
    
    func enableAudioEarMonitoring(enable: Bool) {
        PanoClientService.rtcEngineKit()?.setOption(enable as NSObject, for: .optionAudioEarMonitoring)
    }
    
    func setAudioDeviceVolume(volume: UInt32) {
        PanoClientService.rtcEngineKit()?.setAudioDeviceVolume(volume, with: .audioRecord)
    }
    
    class func hasHeadphonesDevice() -> Bool {
        let route = AVAudioSession.sharedInstance().currentRoute
        for port in route.outputs {
            if  port.portType == AVAudioSession.Port.headphones ||
                port.portType == AVAudioSession.Port.bluetoothLE ||
                port.portType == AVAudioSession.Port.bluetoothHFP ||
                port.portType == AVAudioSession.Port.bluetoothA2DP {
                return true
            }
        }
        return false
    }
}
