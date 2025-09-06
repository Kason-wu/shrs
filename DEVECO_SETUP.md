# DevEco Studio 项目配置指南

## 🛠️ 环境要求

### DevEco Studio 版本
- **推荐版本**: DevEco Studio 5.0.3.900 或更高版本
- **最低版本**: DevEco Studio 4.1.3.500

### HarmonyOS SDK 版本
- **API Level**: 12 (5.0.0)
- **编译SDK版本**: 5.0.0(12)
- **最低兼容版本**: 5.0.0(12)

### Node.js 版本
- **推荐版本**: Node.js 18.x 或 20.x
- **最低版本**: Node.js 16.x

## 🚀 项目配置

### 1. Hvigor 配置
项目使用 Hvigor 5.0.5 版本，确保以下配置正确：

**根目录 hvigorfile.ts**:
```typescript
import { appTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: appTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
```

**entry/hvigorfile.ts**:
```typescript
import { hapTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: hapTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
```

### 2. 依赖版本配置

**根目录 oh-package.json5**:
```json5
{
  "devDependencies": {
    "@ohos/hvigor-ohos-plugin": "5.0.5",
    "@ohos/hvigor": "5.0.5"
  },
  "overrides": {
    "@ohos/hvigor-ohos-plugin": "5.0.5",
    "@ohos/hvigor": "5.0.5"
  }
}
```

**entry/oh-package.json5**:
```json5
{
  "devDependencies": {
    "@ohos/hvigor-ohos-plugin": "5.0.5",
    "@ohos/hvigor": "5.0.5"
  }
}
```

### 3. 构建配置

**build-profile.json5**:
```json5
{
  "modelVersion": "5.0.5",
  "app": {
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compatibleSdkVersion": "5.0.0(12)",
        "runtimeOS": "HarmonyOS"
      }
    ]
  }
}
```

## 🔧 在 Windows 上的设置步骤

### 1. 安装 DevEco Studio
1. 从华为开发者官网下载最新版本的 DevEco Studio
2. 安装时选择完整安装，包括 HarmonyOS SDK
3. 首次启动时配置 SDK 路径

### 2. 配置 SDK
1. 打开 DevEco Studio
2. 进入 **File** → **Settings** → **HarmonyOS SDK**
3. 确保安装了 API 12 (5.0.0) 版本的 SDK
4. 检查 SDK 工具是否完整安装

### 3. 导入项目
1. 选择 **File** → **Open**
2. 选择项目根目录（包含 build-profile.json5 的目录）
3. 等待项目同步完成

### 4. 解决常见问题

#### 问题1: "Invalid exports, no system plugins were found"
**解决方案**:
- 确保 hvigorfile.ts 使用正确的导入：`import { appTasks } from '@ohos/hvigor-ohos-plugin';`
- 检查 Hvigor 版本是否为 5.0.5

#### 问题2: "BUILD FAILED"
**解决方案**:
1. 清理项目缓存：
   ```bash
   # 在项目根目录执行
   ./hvigorw clean
   ```
2. 重新安装依赖：
   ```bash
   ohpm install
   ```
3. 重新构建项目

#### 问题3: SDK 版本不匹配
**解决方案**:
- 在 DevEco Studio 中更新 SDK 到 5.0.0(12)
- 确保 build-profile.json5 中的 compatibleSdkVersion 正确

### 5. 构建和运行
1. 连接 HarmonyOS 设备或启动模拟器
2. 点击 **Run** 按钮或使用快捷键 Shift+F10
3. 选择目标设备进行安装和运行

## 📱 设备要求

### 真机测试
- HarmonyOS 4.0 或更高版本
- 开启开发者模式和 USB 调试

### 模拟器
- 使用 DevEco Studio 内置的 HarmonyOS 模拟器
- 推荐使用 API 12 的模拟器镜像

## 🐛 故障排除

### 常见错误及解决方案

1. **Hvigor 版本冲突**
   - 删除 node_modules 和 .hvigor 目录
   - 重新执行 `ohpm install`

2. **SDK 路径问题**
   - 检查 DevEco Studio 中的 SDK 配置
   - 确保环境变量 HARMONY_HOME 正确设置

3. **编译错误**
   - 检查 ArkTS 语法是否正确
   - 确保使用了正确的 API 版本

4. **模块导入错误**
   - 检查 import 路径是否正确
   - 确保模块文件存在且可访问

## 📞 技术支持

如果遇到其他问题，请参考：
- [HarmonyOS 开发者文档](https://developer.harmonyos.com/)
- [DevEco Studio 用户指南](https://developer.harmonyos.com/cn/develop/deveco-studio)
- [Hvigor 构建工具文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/hvigor-0000001057549201)

## 📋 检查清单

在运行项目前，请确认以下项目：

- [ ] DevEco Studio 版本 ≥ 5.0.3.900
- [ ] HarmonyOS SDK API 12 已安装
- [ ] Node.js 版本 ≥ 16.x
- [ ] 项目 modelVersion 设置为 5.0.5
- [ ] Hvigor 版本为 5.0.5
- [ ] 所有配置文件已正确更新
- [ ] 项目可以成功同步和构建

完成以上配置后，项目应该可以在 DevEco Studio 中正常运行。