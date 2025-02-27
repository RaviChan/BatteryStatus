//
//  BatteryViewModel.swift
//  BatteryStatusApp
//
//  Created by Xing CHEN on 27/2/2025.
//

import Foundation
import Combine
import Dispatch

class BatteryViewModel: ObservableObject {
    @Published var batteryInfo = BatteryInfo()
    @Published var errorMessage: String?

    init() {
        refresh()
    }

    func refresh() {
        let result = shell("ioreg -rn AppleSmartBattery")
        parseBatteryInfo(output: result.output)
    }

    private func parseBatteryInfo(output: String) {
        var info = BatteryInfo()

        let lines = output.components(separatedBy: .newlines)
        //print("lines: \(lines)") // 调试输出
        for line in lines {
            if line.contains("CurrentCapacity") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let valueString = components[1].trimmingCharacters(in: .whitespaces)
                    info.currentCapacity = Int(valueString) ?? 0
                }
            }
            if line.contains("MaxCapacity") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let valueString = components[1].trimmingCharacters(in: .whitespaces)
                    info.maxCapacity = Int(valueString) ?? 0
                }
            }
            if line.contains("DesignCapacity") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let valueString = components[1].trimmingCharacters(in: .whitespaces)
                    info.designCapacity = Int(valueString) ?? 0
                }
            }
            if line.contains("IsCharging") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let value = components[1].trimmingCharacters(in: .whitespaces)
                    info.isCharging = value == "Yes"
                }
            }
            if line.contains("CycleCount") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let valueString = components[1].trimmingCharacters(in: .whitespaces)
                    info.cycleCount = Int(valueString) ?? 0
                }
            }
            if line.contains("Temperature") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let valueString = components[1].trimmingCharacters(in: .whitespaces)
                    info.temperature = (Double(valueString) ?? 0.0) / 100.0
                }
            }
            if line.contains("AvgTimeToFull") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let valueString = components[1].trimmingCharacters(in: .whitespaces)
                    info.avgTimeToFull = Int(valueString) ?? -1
                }
            }
            if line.contains("AvgTimeToEmpty") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let valueString = components[1].trimmingCharacters(in: .whitespaces)
                    let time = Int(valueString) ?? -1
                    info.avgTimeToEmpty = (time == 65535) ? -1 : time // 处理无效数据
                }
            }
//            if line.contains("ExternalConnected") {
//                let components = line.components(separatedBy: "=")
//                if components.count > 1 {
//                    let value = components[1].trimmingCharacters(in: .whitespaces)
//                    info.isOnACPower = value == "Yes"
//                    print("Parsed isOnACPower: \(info.isOnACPower)") // 调试输出
//                }
//            }
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("\"ExternalConnected\"") {
                let components = line.components(separatedBy: "=")
                if components.count > 1 {
                    let value = components[1].trimmingCharacters(in: .whitespaces)
                    info.isOnACPower = value == "Yes"
                    print("Parsed isOnACPower: \(info.isOnACPower)") // 调试输出
                }
            }
        }
        
        // 确保在主线程更新
        if info.designCapacity > 0 {
            DispatchQueue.main.async {
                self.batteryInfo = info
                self.errorMessage = nil
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "无法获取电池信息，请确认设备是否配备电池"
            }
        }
    }

    private func shell(_ command: String) -> (output: String, error: String, exitCode: Int32) {
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = pipe
        task.standardError = errorPipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.launch()

        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let error = String(data: errorData, encoding: .utf8) ?? ""

        task.waitUntilExit()
        return (output, error, task.terminationStatus)
    }
}
