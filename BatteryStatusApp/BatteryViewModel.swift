//
//  BatteryViewModel.swift
//  BatteryStatusApp
//
//  Created by Xing CHEN on 27/2/2025.
//

import Foundation
import Combine
import IOKit
import IOKit.ps

class BatteryViewModel: ObservableObject {
    @Published var batteryInfo = BatteryInfo()
    @Published var errorMessage: String?

    init() {
        refresh()
    }

    func refresh() {
        let batteryInfo = getBatteryInfo()
        DispatchQueue.main.async {
            self.batteryInfo = batteryInfo
            self.errorMessage = batteryInfo.designCapacity > 0 ? nil : "无法获取电池信息，请确认设备是否配备电池"
        }
    }

    private func getBatteryInfo() -> BatteryInfo {
        var info = BatteryInfo()
        
        // 获取电源服务
        let powerSourcesInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSources = IOPSCopyPowerSourcesList(powerSourcesInfo).takeRetainedValue() as Array
        
        // 检查是否有可用的电源信息
        if powerSources.count == 0 {
            return info
        }
        
        // 获取第一个电源的详细信息
        for powerSource in powerSources {
            if let powerSourceInfo = IOPSGetPowerSourceDescription(powerSourcesInfo, powerSource).takeUnretainedValue() as? [String: Any] {
                // 处理电源信息
                info = processBasicPowerInfo(powerSourceInfo: powerSourceInfo)
                
                // 打印调试信息，查看电源信息
                print("电源信息: \(powerSourceInfo)")
                break // 只处理第一个电源
            }
        }
        
        // 获取IOService对象来访问更详细的电池信息
        let service = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleSmartBattery"))
        if service != 0 { // 检查service是否有效
            defer {
                IOObjectRelease(service)
            }
            
            // 获取详细的电池信息
            info = processDetailedBatteryInfo(service: service, currentInfo: info)
            
            // 尝试获取所有可能的时间估计值并打印它们
            let timeProperties = ["TimeRemaining", "AvgTimeToEmpty", "InstantTimeToEmpty", "TimeToEmpty", "ExternalConnected", "IsCharging"]
            for key in timeProperties {
                if let value = getIOKitProperty(service: service, key: key) {
                    print("电池属性 \(key): \(value)")
                }
            }
        }
        
        return info
    }
    
    // BatteryViewModel.swift 中的 processBasicPowerInfo 函数修改

    private func processBasicPowerInfo(powerSourceInfo: [String: Any]) -> BatteryInfo {
        var info = BatteryInfo()
        
        // 获取电源状态
        if let powerSourceState = powerSourceInfo["Power Source State"] as? String {
            print("电源状态 Power Source State: \(powerSourceState)")
            // 根据电源状态设置基本标志
            if powerSourceState == "AC Power" {
                info.isOnACPower = true
                // 在AC电源情况下，进一步判断是否在充电
                if let isCharging = powerSourceInfo["Is Charging"] as? Bool {
                    info.isCharging = isCharging
                    print("充电状态 Is Charging: \(isCharging)")
                }
                
                // 检查 Time to Full Charge 是否为 0
                if let timeToFull = powerSourceInfo["Time to Full Charge"] as? Int, timeToFull == 0 {
                    // 当 Time to Full Charge 为 0 时，强制设置为使用外接电源状态
                    info.isCharging = false
                    print("检测到 Time to Full Charge 为 0，设置为使用外接电源状态")
                }
            } else if powerSourceState == "Battery Power" {
                // 电池供电状态，既不是外接电源也不是充电
                info.isOnACPower = false
                info.isCharging = false
            }
        } else {
            // 如果没有找到Power Source State，则尝试通过其他键获取状态
            if let isOnAC = powerSourceInfo["ExternalConnected"] as? Bool {
                info.isOnACPower = isOnAC
                print("外接电源状态(备用) ExternalConnected: \(isOnAC)")
            }
            
            if let isCharging = powerSourceInfo["IsCharging"] as? Bool {
                info.isCharging = isCharging
                print("充电状态(备用) IsCharging: \(isCharging)")
            }
            
            // 备用逻辑中也检查 Time to Full Charge
            if let timeToFull = powerSourceInfo["Time to Full Charge"] as? Int, timeToFull == 0 {
                info.isCharging = false
                print("检测到 Time to Full Charge 为 0，设置为使用外接电源状态(备用逻辑)")
            }
        }
        
        // 获取基本容量信息
        if let currentCapacity = powerSourceInfo["CurrentCapacity"] as? Int {
            info.currentCapacity = currentCapacity
        }
        
        if let maxCapacity = powerSourceInfo["MaxCapacity"] as? Int {
            info.maxCapacity = maxCapacity
        }
        
        // 根据电源状态获取时间估计
        if info.isCharging {
            // 充电状态，获取充满时间
            if let timeToFull = powerSourceInfo["Time to Full Charge"] as? Int {
                if timeToFull > 0 && timeToFull < 65535 {
                    info.avgTimeToFull = timeToFull
                    print("找到 Time to Full Charge: \(timeToFull)")
                }
            }
        } else if !info.isOnACPower {
            // 电池放电状态，获取放完时间
            if let timeToEmpty = powerSourceInfo["Time to Empty"] as? Int {
                if timeToEmpty > 0 && timeToEmpty < 65535 {
                    info.avgTimeToEmpty = timeToEmpty
                    print("找到 Time to Empty: \(timeToEmpty)")
                }
            }
        }
        
        // 如果没有找到特定时间，尝试使用通用的TimeRemaining作为备用
        if info.isCharging && (info.avgTimeToFull <= 0 || info.avgTimeToFull >= 65535) {
            if let timeRemaining = powerSourceInfo["TimeRemaining"] as? Int {
                if timeRemaining > 0 && timeRemaining < 65535 {
                    info.avgTimeToFull = timeRemaining
                    print("使用通用 TimeRemaining 作为充电时间: \(timeRemaining)")
                }
            }
        } else if !info.isOnACPower && (info.avgTimeToEmpty <= 0 || info.avgTimeToEmpty >= 65535) {
            if let timeRemaining = powerSourceInfo["TimeRemaining"] as? Int {
                if timeRemaining > 0 && timeRemaining < 65535 {
                    info.avgTimeToEmpty = timeRemaining
                    print("使用通用 TimeRemaining 作为放电时间: \(timeRemaining)")
                }
            }
        }
        
        return info
    }
    
    private func processDetailedBatteryInfo(service: io_service_t, currentInfo: BatteryInfo) -> BatteryInfo {
        var info = currentInfo
        
        // 获取设计容量
        if let designCapacity = getIOKitProperty(service: service, key: "DesignCapacity") as? Int {
            info.designCapacity = designCapacity
        }
        
        // 获取循环次数
        if let cycleCount = getIOKitProperty(service: service, key: "CycleCount") as? Int {
            info.cycleCount = cycleCount
        }
        
        // 获取温度
        if let temperature = getIOKitProperty(service: service, key: "Temperature") as? Int {
            info.temperature = Double(temperature) / 100.0
        }
        
        // 尝试获取原始容量值
        if let rawMaxCapacity = getIOKitProperty(service: service, key: "AppleRawMaxCapacity") as? Int {
            if rawMaxCapacity > 1000 && info.maxCapacity < 1000 {
                info.maxCapacity = rawMaxCapacity
            }
        }
        
        if let rawCurrentCapacity = getIOKitProperty(service: service, key: "AppleRawCurrentCapacity") as? Int {
            if rawCurrentCapacity > 1000 && info.currentCapacity < 1000 {
                info.currentCapacity = rawCurrentCapacity
            }
        }
        
        // 尝试获取电池时间信息 (IOKit)
        if info.avgTimeToEmpty <= 0 || info.avgTimeToEmpty >= 65535 {
            if let timeRemaining = getIOKitProperty(service: service, key: "TimeRemaining") as? Int {
                if timeRemaining > 0 && timeRemaining < 65535 {
                    info.avgTimeToEmpty = timeRemaining
                    print("从IOKit找到 TimeRemaining: \(timeRemaining)")
                }
            }
        }
        
        if info.avgTimeToEmpty <= 0 || info.avgTimeToEmpty >= 65535 {
            if let instantTimeToEmpty = getIOKitProperty(service: service, key: "InstantTimeToEmpty") as? Int {
                if instantTimeToEmpty > 0 && instantTimeToEmpty < 65535 {
                    info.avgTimeToEmpty = instantTimeToEmpty
                    print("从IOKit找到 InstantTimeToEmpty: \(instantTimeToEmpty)")
                }
            }
        }
        
        if info.avgTimeToFull <= 0 || info.avgTimeToFull >= 65535 {
            if let instantTimeToFull = getIOKitProperty(service: service, key: "InstantTimeToFull") as? Int {
                if instantTimeToFull > 0 && instantTimeToFull < 65535 {
                    info.avgTimeToFull = instantTimeToFull
                    print("从IOKit找到 InstantTimeToFull: \(instantTimeToFull)")
                }
            }
        }
        
        return info
    }
    
    private func getIOKitProperty(service: io_service_t, key: String) -> Any? {
        let cfKey = key as CFString
        let property = IORegistryEntryCreateCFProperty(service, cfKey, kCFAllocatorDefault, 0)
        return property?.takeUnretainedValue()
    }
}
