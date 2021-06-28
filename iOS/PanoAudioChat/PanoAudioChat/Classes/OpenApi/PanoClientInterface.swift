////
////  PanoClientOpenApi.swift
////  PanoAudioChat
////
////  Created by wenhua.zhang on 2021/6/11.
////

import Foundation

/// 用户角色
public enum PanoUserMode: Int {
    case andience = 0 // 观众
    case anchor = 1 // 主播
}

/// 加入房间配置类
public struct PanoClientConfig {
    /// 用户名
    var userName: String
    /// 房间号码
    var roomId: String
    /// 用户ID
    var userId: UInt64
    /// 用户角色
    var userMode: PanoUserMode
}

public protocol PanoSignalInterface {

    /// 发送消息给房间中某个用户
    func sendMessage(msg: Dictionary<String, Any>, toUser: UInt64) -> Bool;

    /// 广播消息给房间中所有用户
    func broadcastMessage(msg: Dictionary<String, Any>) -> Bool;

    /**
     * ## 根据Key设置属性
     -  important 后续加入房间的用户可以收到属性改变的回调通知
     */
    func setProperty(value: Any?, for key: String) ->Bool;
}

public protocol PanoClientMessageDelegate {
    /// 信令消息回调通知
    func onMessageReceived(_ message: [String: Any], fromUser userId: UInt64);

    /// rtms 状态回调
    func onRtmStateChanged(_ available: Bool);
}

public protocol PanoClientPropertyDelegate {

    /// 属性改变通知
    func onPropertyChanged(_ value: [String: Any], for key: String);
}

public protocol PanoClientDelegate : PanoClientMessageDelegate,
                                     PanoClientPropertyDelegate
{
    /// 显示退出房间的提示框
    func showExitRoomAlert(message: String?);
}

/// PanoClientDelegate 默认消息实现
extension PanoClientDelegate {

    func onMessageReceived(_ message: [String: Any], fromUser userId: UInt64) {}

    func onRtmStateChanged(_ available: Bool) {}

    func showExitRoomAlert(message: String?) {}

    func onPropertyChanged(_ value: [String: Any], for key: String) {}
}
