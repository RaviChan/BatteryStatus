//
//  ContentView.swift
//  BatteryStatusApp
//
//  Created by Xing CHEN on 27/2/2025.
//

import SwiftUI

struct ContentView: View {
    // 使用 @StateObject 初始化 ViewModel
    @StateObject var viewModel = BatteryViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // 错误信息提示
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                // 电池信息显示
                InfoRow(title: "当前电量", value: "\(viewModel.batteryInfo.currentCapacity) mAh")
                InfoRow(title: "最大容量", value: "\(viewModel.batteryInfo.maxCapacity) mAh")
                InfoRow(title: "设计容量", value: "\(viewModel.batteryInfo.designCapacity) mAh")
                InfoRow(title: "健康状态", value: "\(viewModel.batteryInfo.health)%")
                //InfoRow(title: "电源状态", value: viewModel.batteryInfo.isCharging ? "充电中" : "未充电")
                InfoRow(title: "电源状态", value: viewModel.batteryInfo.chargingStatusDescription)
                InfoRow(title: "剩余时间", value: viewModel.batteryInfo.timeRemainingDescription)
                InfoRow(title: "循环次数", value: "\(viewModel.batteryInfo.cycleCount)")
                InfoRow(title: "温度", value: String(format: "%.1f°C", viewModel.batteryInfo.temperature))
            }

            // 刷新按钮
            Button(action: {
                viewModel.refresh() // 调用 ViewModel 的刷新方法
            }) {
                Label("刷新", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            viewModel.refresh() // 视图出现时自动刷新数据
        }
    }
}

// 自定义信息行视图
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body.monospacedDigit()) // 使用等宽字体显示数值
        }
        .padding(.vertical, 5)
    }
}
