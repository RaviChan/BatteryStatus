# Battery Status Monitor

<!-- Language Switch Buttons -->
<div align="right">
  <button onclick="switchLanguage('en')">English</button>
  <button onclick="switchLanguage('zh')">中文</button>
</div>

<!-- English Content -->
<div id="en">
  ![Swift](https://img.shields.io/badge/Swift-5.7-orange) ![Platform](https://img.shields.io/badge/Platform-macOS-blue) ![License](https://img.shields.io/badge/License-MIT-green)

  A macOS application to monitor battery status, including charge level, health, cycle count, temperature, and charging/discharging status. Built with Swift and SwiftUI.

  ## Features

  - **Battery Level**: Current charge level and maximum capacity.
  - **Battery Health**: Health percentage based on design capacity.
  - **Cycle Count**: Total charge cycles of the battery.
  - **Temperature**: Current battery temperature.
  - **Charging Status**: Displays whether the battery is charging, discharging, or connected to power.
  - **Time Remaining**: Estimated time to full charge or remaining usage time.
  - **Refresh Button**: Manually refresh battery information.

  ## Requirements

  - macOS 11.0 or later.
  - Xcode 13 or later.

  ## Installation

  ### 1. Clone the Repository
  ```bash
  git clone https://github.com/RaviChan/BatteryStatus.git
  cd BatteryStatus
  ```

  ### 2. Open in Xcode
  - Open `BatteryMonitor.xcodeproj` in Xcode.

  ### 3. Build and Run
  - Select the target device (e.g., "My Mac").
  - Click **Run** (or press `Cmd + R`).

  ## Usage

  1. Launch the application.
  2. View real-time battery information.
  3. Click the **Refresh** button to update the data.

  ## License

  This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

  ## Contributing

  Contributions are welcome! Please open an issue or submit a pull request.

  ## Author

  - **RaviChen**
    - GitHub: [RaviChan](https://github.com/RaviChan)
</div>

<!-- Chinese Content -->
<div id="zh" style="display: none;">
  ![Swift](https://img.shields.io/badge/Swift-5.7-orange) ![Platform](https://img.shields.io/badge/Platform-macOS-blue) ![License](https://img.shields.io/badge/License-MIT-green)

  一款用于监控电池状态的 macOS 应用程序，包括电量、健康度、循环次数、温度以及充电/放电状态。使用 Swift 和 SwiftUI 构建。

  ## 功能

  - **电量显示**：当前电量和最大容量。
  - **电池健康度**：基于设计容量的健康百分比。
  - **循环次数**：电池的总充电循环次数。
  - **温度**：当前电池温度。
  - **充电状态**：显示电池正在充电、放电或连接电源。
  - **剩余时间**：充满电的预计时间或剩余使用时间。
  - **刷新按钮**：手动刷新电池信息。

  ## 要求

  - macOS 11.0 或更高版本。
  - Xcode 13 或更高版本。

  ## 安装

  ### 1. 克隆仓库
  ```bash
  git clone https://github.com/RaviChan/BatteryStatus.git
  cd BatteryStatus
  ```

  ### 2. 在 Xcode 中打开
  - 在 Xcode 中打开 `BatteryMonitor.xcodeproj`。

  ### 3. 编译并运行
  - 选择目标设备（例如“My Mac”）。
  - 点击 **Run**（或按 `Cmd + R`）。

  ## 使用方法

  1. 启动应用程序。
  2. 查看实时电池信息。
  3. 点击 **刷新** 按钮以更新数据。

  ## 许可证

  本项目基于 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

  ## 贡献

  欢迎贡献！请提交 Issue 或 Pull Request。

  ## 作者

  - **RaviChen**
  - GitHub: [RaviChan](https://github.com/RaviChan)
</div>

<!-- Language Switch Script -->
<script>
  function switchLanguage(lang) {
    document.getElementById('en').style.display = (lang === 'en') ? 'block' : 'none';
    document.getElementById('zh').style.display = (lang === 'zh') ? 'block' : 'none';
  }
  // Default to English
  switchLanguage('en');
</script>
