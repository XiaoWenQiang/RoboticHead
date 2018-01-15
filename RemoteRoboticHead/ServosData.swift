//
//  ServosData.swift
//  RemoteRoboticHead
//
//  Created by QiaoWu on 2018/1/13.
//  Copyright © 2018年 EXdoll. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

//蓝牙
var dataperipheral: CBPeripheral!
var datawriteCharacteristic: CBCharacteristic!

//蓝牙传输用，待测试看能否使用全局变量
//写入数据
public func writeToPeripheral(bytes:[UInt8]) {
    if datawriteCharacteristic != nil {
        let data:NSData = dataWithHexstring(bytes: bytes)
        dataperipheral!.writeValue(data as Data, for: datawriteCharacteristic!, type: .withoutResponse)
    } else{
        print("无法发送数据")
    }
}
//数组换算
func dataWithHexstring(bytes:[UInt8]) -> NSData {
    let data = NSData(bytes: bytes, length: bytes.count)
    return data
}

//电动机数据
struct Servos {
    var name:String
    var currentAngle:UInt8
    var minA:Int
    var maxA:Int
}
//保存表情动作数据
struct OneFaceAction {
    var name:String = ""
    var actionData:[UInt8] = [90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90]
}
//设备屏幕尺寸
public let SCREEN_WIDTH=UIScreen.main.bounds.size.width
public let SCREEN_HEIGHT=UIScreen.main.bounds.size.height

//获取视图尺寸
public func VIEW_WIDTH(view:UIView)->CGFloat{
    return view.frame.size.width
}
public func VIEW_HEIGHT(view:UIView)->CGFloat{
    return view.frame.size.height
}

//蓝牙传输数据21
var blueData:[UInt8] = [90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90]
//滑动块用列表数据
var servosData = [
    Servos(name: "左侧眉毛", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "右侧眉毛", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "眼睛左右", currentAngle: 90, minA: 10, maxA: 170),
    Servos(name: "眼睛上下", currentAngle: 90, minA: 10, maxA: 170),
    Servos(name: "左上眼皮", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "右上眼皮", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "左下眼皮", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "右下眼皮", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "左唇上下", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "右唇上下", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "左唇前后", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "右唇前后", currentAngle: 90, minA: 20, maxA: 160),
    Servos(name: "嘴部张合", currentAngle: 90, minA: 10, maxA: 170),
    Servos(name: "头部旋转", currentAngle: 90, minA: 40, maxA: 140),
    Servos(name: "头部前后", currentAngle: 90, minA: 40, maxA: 140),
    Servos(name: "头部左右", currentAngle: 90, minA: 40, maxA: 140),
    Servos(name: "左肩上下", currentAngle: 90, minA: 40, maxA: 140),
    Servos(name: "右肩上下", currentAngle: 90, minA: 40, maxA: 140),
    Servos(name: "左肩前后", currentAngle: 90, minA: 40, maxA: 140),
    Servos(name: "右肩前后", currentAngle: 90, minA: 40, maxA: 140),
    Servos(name: "呼吸频率", currentAngle: 90, minA: 10, maxA: 170)
]
//蓝牙传输数据更新 需要修改，让其本身就是UInt8
public func bluedataupdate(){
    for i in 0...20 {
        blueData[i] =  servosData[i].currentAngle
    }
}
//ActionListView页面使用的数据列表
var actionDatas:[OneFaceAction] = []
//单独表情动作名称列表和角度
var actionNameList:[String] = []
var actionAngleList:[[UInt8]] = []
//数据保存路径-单独表情列表名称
let actionNameListFilePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/actionNameList.dat"
//数据保存路径-单独表情列表角度
let actionAngleListFilePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/actionAngleList.dat"
//保存单独表情列表名称和角度
public func saveActionList(){
    //规划储存的列表
    actionNameList = []
    actionAngleList = []
    if(actionDatas.count>0){
    for i in 0..<actionDatas.count{
        actionNameList.append(actionDatas[i].name)
        actionAngleList.append(actionDatas[i].actionData)
        }
    }else{
        actionAngleList = [[90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90]]
        actionNameList = ["预设"]
    }
    //保存到路径
    NSKeyedArchiver.archiveRootObject(actionNameList, toFile: actionNameListFilePath)
    NSKeyedArchiver.archiveRootObject(actionAngleList, toFile: actionAngleListFilePath)
}
//读取单独表情列表名称和角度
public func readActionList(){
    //检查是否有储存的表情和角度文件
    let fileManager = FileManager.default
    if(!fileManager.fileExists(atPath: actionNameListFilePath)){
        //这里可以预存一些基础表情
        actionAngleList = [[90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90,90]]
        actionNameList = ["预设"]
        saveActionList()
    }
    //从路径读取
    actionNameList = NSKeyedUnarchiver.unarchiveObject(withFile: actionNameListFilePath) as! Array
    actionAngleList = NSKeyedUnarchiver.unarchiveObject(withFile: actionAngleListFilePath) as! Array
    //从新规划ActionListView页面列表数据
    actionDatas = []
    for i in 0..<actionNameList.count{
        actionDatas.append(OneFaceAction(name: actionNameList[i], actionData: actionAngleList[i]))
    }
}



