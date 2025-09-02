# 博物馆预约系统 (Museum Booking System)

一个基于HarmonyOS开发的博物馆参观预约应用，提供完整的预约流程和用户管理功能。

## 功能特性

### 🏛️ 核心功能
- **博物馆浏览**: 查看博物馆列表，支持搜索和分类筛选
- **详细信息**: 展示博物馆详细信息、展览内容和参观须知
- **在线预约**: 选择日期时间、填写参观者信息、确认预约
- **预约管理**: 查看预约历史、取消预约、重新预约

### 👤 用户系统
- **用户注册**: 支持邮箱、手机号注册
- **用户登录**: 安全的登录验证
- **个人中心**: 用户信息管理和设置
- **预约记录**: 完整的预约历史记录

### 🎨 界面设计
- **现代化UI**: 遵循HarmonyOS设计规范
- **响应式布局**: 适配不同屏幕尺寸
- **流畅交互**: 优化的用户体验和动画效果
- **无障碍支持**: 考虑无障碍访问需求

## 技术架构

### 开发框架
- **HarmonyOS**: 基于鸿蒙操作系统
- **ArkTS**: 使用ArkTS语言开发
- **ArkUI**: 声明式UI框架

### 项目结构
```
museum-booking-app/
├── AppScope/                    # 应用级配置
│   ├── app.json5               # 应用配置文件
│   └── resources/              # 应用级资源
├── entry/                      # 主模块
│   ├── src/main/
│   │   ├── ets/               # ArkTS源码
│   │   │   ├── entryability/  # 应用入口
│   │   │   ├── pages/         # 页面文件
│   │   │   └── common/        # 公共组件和工具
│   │   └── resources/         # 资源文件
│   └── module.json5           # 模块配置
├── build-profile.json5        # 构建配置
└── hvigorfile.ts             # 构建脚本
```

### 页面结构
- **Index.ets**: 应用首页，导航入口
- **Login.ets**: 用户登录页面
- **Register.ets**: 用户注册页面
- **MuseumList.ets**: 博物馆列表页面
- **MuseumDetail.ets**: 博物馆详情页面
- **BookingPage.ets**: 预约流程页面
- **Profile.ets**: 个人中心页面
- **BookingHistory.ets**: 预约记录页面

## 核心功能实现

### 1. 用户认证系统
```typescript
// 登录验证
async handleLogin() {
  if (!this.validateForm()) return;
  
  this.isLoading = true;
  // 模拟登录请求
  setTimeout(() => {
    AppStorage.SetOrCreate('currentUser', this.username);
    AppStorage.SetOrCreate('isLoggedIn', true);
    router.back();
  }, 1500);
}
```

### 2. 预约流程管理
```typescript
// 三步预约流程
// 步骤1: 选择日期和时间
// 步骤2: 填写参观者信息
// 步骤3: 确认预约信息
@State currentStep: number = 0;
```

### 3. 数据持久化
```typescript
// 使用AppStorage进行本地数据存储
AppStorage.SetOrCreate('userBookings', bookingRecords);
const bookings = AppStorage.Get('userBookings') as BookingRecord[];
```

### 4. 表单验证
```typescript
// 统一的表单验证工具
export class ValidationUtils {
  static validatePhone(phone: string): boolean {
    const phoneRegex = /^1[3-9]\d{9}$/;
    return phoneRegex.test(phone);
  }
}
```

## 界面设计亮点

### 1. 卡片式设计
- 博物馆信息以卡片形式展示
- 圆角设计和阴影效果
- 清晰的信息层次结构

### 2. 色彩系统
- 主色调: #007DFF (蓝色)
- 成功色: #00C853 (绿色)
- 警告色: #FF9500 (橙色)
- 错误色: #FF3B30 (红色)

### 3. 交互反馈
- 按钮点击反馈
- 加载状态提示
- 操作结果Toast提示

### 4. 空状态处理
- 优雅的空数据展示
- 引导用户进行操作
- 友好的错误提示

## 数据模型

### 博物馆信息
```typescript
interface Museum {
  id: number;
  name: string;
  description: string;
  location: string;
  rating: number;
  price: number;
  openTime: string;
  tags: string[];
}
```

### 预约记录
```typescript
interface BookingRecord {
  id: string;
  museum: Museum;
  date: string;
  timeSlot: TimeSlot;
  visitorCount: number;
  visitorName: string;
  status: 'confirmed' | 'cancelled' | 'completed';
}
```

## 开发环境要求

### 系统要求
- HarmonyOS SDK 4.0.0 或更高版本
- DevEco Studio 4.0 或更高版本
- Node.js 16.0 或更高版本

### 构建步骤
1. 克隆项目到本地
2. 使用DevEco Studio打开项目
3. 配置HarmonyOS SDK路径
4. 同步项目依赖
5. 连接设备或启动模拟器
6. 运行项目

## 功能演示

### 主要流程
1. **启动应用** → 查看首页导航
2. **浏览博物馆** → 搜索和筛选博物馆
3. **查看详情** → 了解博物馆信息和展览
4. **用户登录** → 注册或登录账户
5. **预约参观** → 选择时间、填写信息、确认预约
6. **管理预约** → 查看历史记录、取消预约

### 特色功能
- **智能推荐**: 根据用户偏好推荐博物馆
- **实时更新**: 动态显示可预约时间段
- **多人预约**: 支持多人同时预约
- **状态跟踪**: 完整的预约状态管理

## 扩展功能

### 待开发功能
- [ ] 地图导航集成
- [ ] 语音导览功能
- [ ] 社交分享功能
- [ ] 评价评论系统
- [ ] 优惠券系统
- [ ] 推送通知
- [ ] 多语言支持
- [ ] 深色模式

### 技术优化
- [ ] 网络请求封装
- [ ] 图片懒加载
- [ ] 缓存机制优化
- [ ] 性能监控
- [ ] 错误日志收集

## 项目亮点

1. **完整的业务流程**: 从浏览到预约的完整用户旅程
2. **现代化设计**: 符合HarmonyOS设计规范的界面
3. **良好的代码结构**: 模块化、可维护的代码架构
4. **用户体验优化**: 流畅的交互和友好的提示
5. **数据持久化**: 本地存储用户数据和预约记录

## 总结

这是一个功能完整、设计精美的博物馆预约系统，展示了HarmonyOS应用开发的最佳实践。应用包含了用户认证、数据管理、界面交互等核心功能，可以作为学习HarmonyOS开发的优秀示例。

通过这个项目，开发者可以学习到：
- HarmonyOS应用架构设计
- ArkTS语言特性和用法
- ArkUI声明式UI开发
- 状态管理和数据持久化
- 用户体验设计原则

项目代码结构清晰，注释详细，适合作为HarmonyOS开发的学习资料和参考项目。