# 项目构建指南

## 🚀 快速开始

### Windows 用户
1. 双击运行 `fix-windows-build.bat` 脚本
2. 等待脚本执行完成
3. 在 DevEco Studio 中重新打开项目

### macOS/Linux 用户
```bash
# 清理缓存
rm -rf .hvigor node_modules entry/node_modules

# 重新安装依赖
ohpm install
cd entry && ohpm install && cd ..

# 清理构建
./hvigorw clean

# 构建项目
./hvigorw assembleHap
```

## 🔧 手动修复步骤

如果自动脚本无法解决问题，请按以下步骤手动修复：

### 1. 检查 DevEco Studio 版本
确保使用 DevEco Studio 5.0.3.900 或更高版本

### 2. 检查 SDK 配置
- 打开 DevEco Studio
- 进入 File → Settings → HarmonyOS SDK
- 确保安装了 API 12 (5.0.0) 版本

### 3. 更新项目配置

**检查 hvigorfile.ts**:
```typescript
import { appTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: appTasks,
  plugins:[]
}
```

**检查 oh-package.json5**:
```json5
{
  "devDependencies": {
    "@ohos/hvigor-ohos-plugin": "5.0.5",
    "@ohos/hvigor": "5.0.5"
  }
}
```

**检查 build-profile.json5**:
```json5
{
  "modelVersion": "5.0.5",
  "app": {
    "products": [
      {
        "compatibleSdkVersion": "5.0.0(12)"
      }
    ]
  }
}
```

### 4. 清理和重建
```bash
# 删除缓存目录
rm -rf .hvigor
rm -rf node_modules
rm -rf entry/node_modules

# 重新安装依赖
ohpm install

# 进入 entry 目录
cd entry
ohpm install
cd ..

# 清理构建
./hvigorw clean

# 重新构建
./hvigorw assembleHap
```

## ❌ 常见错误及解决方案

### 错误1: "Invalid exports, no system plugins were found"
**原因**: hvigorfile.ts 配置错误
**解决**: 确保使用 `import { appTasks }` 而不是 `import { hapTasks }`

### 错误2: "BUILD FAILED"
**原因**: 版本不匹配或依赖问题
**解决**: 
1. 检查所有配置文件中的版本号
2. 清理缓存重新安装依赖
3. 确保 DevEco Studio 和 SDK 版本正确

### 错误3: "Module not found"
**原因**: 依赖安装不完整
**解决**: 
1. 删除 node_modules 目录
2. 重新执行 `ohpm install`
3. 检查网络连接

### 错误4: "SDK version mismatch"
**原因**: SDK 版本配置不正确
**解决**: 
1. 在 DevEco Studio 中更新 SDK
2. 检查 build-profile.json5 中的 compatibleSdkVersion
3. 确保使用 API 12 (5.0.0)

## 🔍 调试技巧

### 1. 查看详细错误信息
```bash
./hvigorw assembleHap --stacktrace --info
```

### 2. 检查依赖版本
```bash
ohpm list
```

### 3. 验证配置
```bash
# 检查 Node.js 版本
node --version

# 检查 ohpm 版本
ohpm --version
```

### 4. 清理所有缓存
```bash
# Windows
rmdir /s /q .hvigor
rmdir /s /q node_modules
rmdir /s /q entry\node_modules

# macOS/Linux
rm -rf .hvigor node_modules entry/node_modules
```

## 📞 获取帮助

如果问题仍然存在，请：

1. 查看 `DEVECO_SETUP.md` 详细配置指南
2. 检查 [HarmonyOS 开发者文档](https://developer.harmonyos.com/)
3. 确保所有环境要求都已满足

## ✅ 验证构建成功

构建成功后，您应该看到：
- 在 `entry/build/default/outputs/default/` 目录下生成 HAP 文件
- DevEco Studio 中没有编译错误
- 可以成功运行到设备或模拟器

## 🎯 下一步

构建成功后：
1. 连接 HarmonyOS 设备或启动模拟器
2. 在 DevEco Studio 中点击运行按钮
3. 体验完整的博物馆预约系统功能