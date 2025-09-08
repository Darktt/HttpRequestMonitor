# HttpRequestMonitor

[![Swift-5.5](https://img.shields.io/badge/Swift-5.5-red.svg?style=plastic&logo=Swift&logoColor=white&link=)](https://developer.apple.com/swift/)
[![example workflow](https://github.com/Darktt/HttpRequestMonitor/actions/workflows/main.yml/badge.svg)]()

一個專為 macOS 設計的 HTTP 請求監控工具，協助開發者即時監控和分析 API 請求數據。

## 🌟 功能特色

- **🚀 即時監控**: 即時攔截並顯示所有 HTTP 請求
- **📊 詳細分析**: 完整顯示請求標頭、查詢參數和請求內容
- **📝 多格式支援**: 支援 JSON、表單數據、multipart/form-data 等多種內容格式
- **🖼️ 檔案上傳支援**: 完整解析 multipart/form-data 格式，包含檔案上傳功能
- **🎨 現代化介面**: 採用 SwiftUI 打造，支援 Light/Dark Mode
- **🔍 即時搜尋**: 快速搜尋和篩選請求記錄
- **🗂️ 清晰分類**: 依據不同的內容類型自動分類顯示

## 📋 系統需求

- macOS 12.0 或更高版本
- Xcode 16.4 或更高版本
- Swift 5.5+

## 🚀 快速開始

### 安裝方式

1. **從源碼編譯**
   ```bash
   git clone https://github.com/Darktt/HttpRequestMonitor.git
   cd HttpRequestMonitor
   open HttpRequestMonitor.xcodeproj
   ```

2. **使用 xcodebuild 編譯**
   ```bash
   xcodebuild -scheme HttpRequestMonitor -platform macOS build
   ```

### 使用方法

1. 啟動 HttpRequestMonitor 應用程式
2. 點選「Start」按鈕開始監控
3. 應用程式將在指定埠號啟動 HTTP 伺服器
4. 設定您的應用程式或測試工具將請求發送至監控伺服器
5. 在介面中即時查看攔截到的請求詳情

## 🏗️ 架構設計

### 核心架構
- **Redux 狀態管理**: 採用 Redux 模式管理應用狀態
- **SwiftUI 介面**: 現代化的宣告式 UI 框架
- **Network Framework**: 使用 Apple 原生網路框架實現 HTTP 伺服器

### 主要元件
- `MonitorStore`: 全域狀態儲存管理
- `HTTPService`: HTTP 伺服器核心服務
- `Request`: HTTP 請求數據模型
- `MainView`: 主要使用者介面

## 🛠️ 開發指南

### 編譯專案
```bash
xcodebuild -scheme HttpRequestMonitor -platform macOS build
```

### 執行測試
```bash
xcodebuild -scheme HttpRequestMonitor -platform macOS test
```

### 執行測試計劃
```bash
xcodebuild test -testPlan HttpRequestMonitor.xctestplan
```

## 📱 介面截圖

應用程式採用三欄式設計：
- **功能列**: 包含開始/停止監控按鈕和清理功能
- **請求列表**: 左側邊欄顯示所有攔截的請求
- **詳細檢視**: 右側主要區域顯示選中請求的詳細資訊

## 🔧 支援的內容格式

- `application/json` - JSON 數據
- `application/x-www-form-urlencoded` - 表單編碼數據
- `multipart/form-data` - 多部分表單數據（含檔案上傳）
- `text/plain` - 純文字內容
- 各種圖像格式（PNG, JPEG, GIF 等）
- 各種檔案格式（PDF, ZIP, Office 文件等）

## 🤝 貢獻指南

歡迎提交 Pull Request 或回報問題！請確保：

1. 遵循現有的程式碼風格
2. 為新功能添加適當的測試
3. 更新相關文件

## 📜 授權條款

本專案採用 [MIT License](LICENSE) 授權。

## 🎯 未來規劃

- [ ] 支援 HTTPS 監控
- [ ] 加入請求匯出功能
- [ ] 支援自訂篩選器
- [ ] 加入效能分析工具
- [ ] 支援 WebSocket 監控

## 📞 技術支援

如有任何問題或建議，請透過 GitHub Issues 回報。

---

**開發者**: Eden  
**最後更新**: 2025年8月
