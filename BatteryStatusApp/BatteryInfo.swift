//
//  BatteryInfo.swift
//  BatteryStatusApp
//
//  Created by Xing CHEN on 27/2/2025.
//

struct BatteryInfo {
    var currentCapacity: Int = 0
    var maxCapacity: Int = 0
    var designCapacity: Int = 0
    var isCharging: Bool = false
    var cycleCount: Int = 0
    var temperature: Double = 0.0
    var avgTimeToFull: Int = -1 // 充满剩余时间（分钟），-1 表示未知
    var avgTimeToEmpty: Int = -1 // 放电剩余时间（分钟），-1 表示未知
    var isOnACPower: Bool = false // 是否使用外接电源
    
    // 计算电量百分比
    var percentage: String {
        guard maxCapacity > 0 else { return "0.00%" }
        let percent = Double(currentCapacity) / Double(maxCapacity) * 100
        return String(format: "%.2f%%", percent)
    }

    var health: Int {
        guard designCapacity > 0 else { return 0 }
        return Int(Double(maxCapacity) / Double(designCapacity) * 100)
    }

    var timeRemainingDescription: String {
        if isOnACPower && !isCharging {
            return "使用外接电源中"
        }
        if isCharging {
            if avgTimeToFull <= 0 || avgTimeToFull >= 65534 {
                return "充电中，剩余时间未知"
            }
            return formatTime(minutes: avgTimeToFull, prefix: "充满剩余时间：")
        } else {
            if avgTimeToEmpty <= 0 || avgTimeToEmpty >= 65534 {
                return "放电中，剩余时间未知"
            }
            return formatTime(minutes: avgTimeToEmpty, prefix: "剩余使用时间：")
        }
    }
    
    // 格式化时间显示，将分钟转换为小时和分钟
    private func formatTime(minutes: Int, prefix: String) -> String {
        if minutes < 60 {
            return "\(prefix)\(minutes) 分钟"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "\(prefix)\(hours) 小时"
            } else {
                return "\(prefix)\(hours) 小时 \(mins) 分钟"
            }
        }
    }
    
    var chargingStatusDescription: String {
        if isCharging {
            return "充电中"
        } else if isOnACPower {
            return "使用外接电源"
        } else {
            return "放电中"
        }
    }
}
