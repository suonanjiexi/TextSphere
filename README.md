# TextSphere App - 文字空间社交应用

TextSphere是一款基于Flutter开发的文字社交应用，专注于提供高质量的文字交流体验。用户可以在这里分享想法、加入话题讨论、建立兴趣圈子，以及与好友私聊。

## 功能特性

- 📱 **多平台支持**：iOS、Android、Web一体化体验
- 💬 **即时通讯**：支持一对一聊天，消息实时送达
- 🔔 **消息通知**：重要消息提醒，不错过任何互动
- 🏙️ **内容广场**：发现热门话题和有趣内容
- 👥 **兴趣圈子**：加入或创建基于共同兴趣的小组
- 🔒 **账户管理**：安全的注册、登录和个人资料管理
- 🌙 **暗黑模式**：保护眼睛，节省电量

## 应用架构

TextSphere采用Clean Architecture架构，将应用分为以下层次：

1. **表示层（Presentation）**：UI组件和状态管理
   - 页面(Pages)：应用的各个屏幕
   - 组件(Components)：可复用的UI组件
   - BLoC：管理UI状态和业务逻辑

2. **领域层（Domain）**：包含业务逻辑和规则
   - 实体(Entities)：核心业务模型
   - 用例(Use Cases)：应用特定的业务规则
   - 仓库接口(Repository Interfaces)：定义数据层的抽象接口

3. **数据层（Data）**：负责数据获取和持久化
   - 仓库实现(Repositories)：实现领域层定义的接口
   - 数据源(Data Sources)：本地和远程数据源
   - 模型(Models)：数据传输对象(DTOs)

## 技术栈

- **Flutter SDK**: ^3.7.2
- **状态管理**: flutter_bloc ^8.1.3
- **路由管理**: go_router ^14.8.1
- **依赖注入**: get_it ^7.6.4
- **网络请求**: dio ^5.3.3
- **实时通信**: socket_io_client ^2.0.3+1
- **本地存储**: shared_preferences ^2.2.1
- **UI适配**: flutter_screenutil ^5.9.0
- **图像处理**: cached_network_image ^3.3.0, image_picker ^1.0.4
- **错误处理**: dartz ^0.10.1
- **UI组件**: flutter_spinkit ^5.2.0, carousel_slider ^4.2.1, shimmer ^3.0.0

## 项目结构

```
lib/                           # 应用主目录
├── main.dart                  # 应用入口点和初始化
├── components/                # 可复用UI组件目录
├── core/                      # 核心功能和配置
│   ├── auth/                  # 认证相关核心功能
│   ├── cache/                 # 缓存管理
│   ├── di/                    # 依赖注入配置
│   ├── error/                 # 错误处理
│   ├── network/               # 网络相关配置
│   ├── router/                # 路由配置
│   ├── routes/                # 路由定义
│   └── theme/                 # 应用主题配置
├── data/                      # 数据层
│   ├── datasources/           # 数据源(本地和远程)
│   ├── models/                # 数据模型(DTOs)
│   └── repositories/          # 仓库实现
├── domain/                    # 领域层
│   ├── entities/              # 业务实体
│   ├── repositories/          # 仓库接口
│   └── usecases/              # 用例实现
├── models/                    # 公共模型
├── presentation/              # 表示层
│   ├── blocs/                 # Bloc状态管理
│   ├── pages/                 # 应用页面
│   └── widgets/               # UI组件
└── utils/                     # 工具类
    ├── analytics/             # 分析工具
    ├── app_logger.dart        # 日志工具
    ├── network_manager.dart   # 网络管理工具
    ├── offline_manager.dart   # 离线功能管理
    └── ... (其他工具类)
```

更详细的项目结构说明请参考 [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md)

## 项目设置与运行

### 环境要求
- Flutter SDK: ^3.7.2
- Dart SDK: ^3.0.0

### 安装步骤
1. 克隆项目代码
2. 执行 `flutter pub get` 安装依赖
3. 复制 `.env.example` 为 `.env` 并配置环境变量
4. 执行 `flutter run` 运行项目

## 主要功能模块

### 圈子系统
- 圈子列表和搜索
- 圈子详情页面
- 圈子内帖子浏览和筛选
- 创建和发布帖子
- 加入/退出圈子

### 消息系统
- 私聊消息列表
- 聊天详情页面
- 消息发送和接收
- 消息状态管理

### 内容广场
- 内容推荐和分类浏览
- 内容搜索
- 内容互动（点赞、评论）
- 热门话题和趋势

### 用户系统
- 用户注册和登录
- 个人资料管理
- 关注和粉丝系统

### 离线功能系统
- 网络连接状态监测
- 离线数据缓存
- 挂起操作管理
- 网络恢复后自动同步
- 离线状态显示组件

## 开发进度

### 已完成
- ✅ 项目基础架构搭建
- ✅ 领域层实体定义
- ✅ 仓库接口设计
- ✅ 核心用例实现
- ✅ API客户端实现
- ✅ Socket实时通信客户端
- ✅ 依赖注入系统
- ✅ 主题与样式系统
- ✅ 认证BLoC实现
- ✅ 通用UI组件库
- ✅ 圈子列表和详情页面
- ✅ 圈子内帖子创建功能
- ✅ 消息列表页面
- ✅ 内容广场基本功能
- ✅ 离线功能系统实现

### 进行中
- 🔄 数据层仓库完整实现
- 🔄 帖子详情页功能完善
- 🔄 消息实时通信模块
- 🔄 个人资料页面
- 🔄 关注和粉丝系统

### 待完成
- ⏳ 图片和媒体内容优化
- ⏳ 消息通知系统
- ⏳ 性能优化
- ⏳ 国际化支持
- ⏳ 单元测试和集成测试
- ⏳ 文档完善

### TextSphere 应用截图展示

以下是TextSphere应用的主要界面和功能展示：

#### 1. 应用启动界面
<img src="assets/images/project/截屏2025-05-11%2023.23.40.png" alt="启动界面" width="250" height="420"/>

#### 2. 登录注册界面
<img src="assets/images/project/截屏2025-05-11%2023.23.47.png" alt="登录注册界面" width="250" height="420"/>

#### 3. 内容广场
<img src="assets/images/project/截屏2025-05-11%2023.23.59.png" alt="内容广场" width="250" height="420"/>

#### 4. 热门话题浏览
<img src="assets/images/project/截屏2025-05-11%2023.24.09.png" alt="热门话题浏览" width="250" height="420"/>

#### 5. 个性化推荐
<img src="assets/images/project/截屏2025-05-11%2023.24.16.png" alt="个性化推荐" width="250" height="420"/>

#### 6. 话题详情页
<img src="assets/images/project/截屏2025-05-11%2023.24.24.png" alt="话题详情页" width="250" height="420"/>

#### 7. 兴趣圈子列表
<img src="assets/images/project/截屏2025-05-11%2023.24.36.png" alt="兴趣圈子列表" width="250" height="420"/>

#### 8. 圈子详情页
<img src="assets/images/project/截屏2025-05-11%2023.24.43.png" alt="圈子详情页" width="250" height="420"/>

#### 9. 创建内容
<img src="assets/images/project/截屏2025-05-11%2023.24.51.png" alt="创建内容" width="250" height="420"/>

#### 10. 消息列表
<img src="assets/images/project/截屏2025-05-11%2023.24.56.png" alt="消息列表" width="250" height="420"/>

#### 11. 聊天详情
<img src="assets/images/project/截屏2025-05-11%2023.25.06.png" alt="聊天详情" width="250" height="420"/>

#### 12. 个人主页
<img src="assets/images/project/截屏2025-05-11%2023.25.12.png" alt="个人主页" width="250" height="420"/>

#### 13. 设置页面
<img src="assets/images/project/截屏2025-05-11%2023.25.21.png" alt="关注列表" width="250" height="420"/>

<img src="assets/images/project/截屏2025-05-11%2023.25.29.png" alt="设置页面" width="250" height="420"/>

---

## 贡献指南

欢迎提交问题报告和功能建议。如需贡献代码，请遵循以下流程：
1. Fork 项目仓库
2. 创建功能分支
3. 提交变更
4. 创建Pull Request

## 设计与原则

- 遵循Material Design 3设计规范
- 采用响应式布局，适配不同尺寸设备
- 使用BLoC模式进行状态管理
- 实现适当的错误处理和日志记录
- 保持代码清晰和可维护

# TextSphere 应用 - 离线功能

## 离线管理器

离线管理器 (`OfflineManager`) 是TextSphere应用的核心组件之一，用于处理网络连接不稳定或离线状态下的数据同步问题。它采用了单例模式设计，确保在整个应用中只有一个实例负责离线数据管理。

### 主要功能

1. **网络状态监测**
   - 监听设备网络连接状态变化
   - 识别网络类型（WiFi、移动数据、无连接）
   - 提供网络状态变化的事件流

2. **挂起操作管理**
   - 在离线状态下保存用户操作
   - 保存操作类型（创建、更新、删除）
   - 保存资源类型（帖子、评论、用户、消息）
   - 保存操作相关数据

3. **数据同步**
   - 当网络连接恢复时自动同步挂起的操作
   - 支持手动触发同步
   - 提供同步状态和结果通知

4. **数据缓存**
   - 缓存关键数据供离线使用
   - 管理缓存过期和更新

### 技术实现

- 使用 `connectivity_plus` 库监测网络状态
- 使用 `shared_preferences` 存储挂起的操作和缓存数据
- 使用 `Stream` 提供实时状态通知
- 实现了重试机制和错误处理

### 使用方法

1. **初始化**
   ```dart
   final offlineManager = OfflineManager();
   await offlineManager.init();
   ```

2. **添加挂起操作**
   ```dart
   await offlineManager.addPendingOperation(
     PendingOperation(
       type: OperationType.create,
       resourceType: ResourceType.post,
       resourceId: 'temp_id',
       data: { 'title': '新帖子', 'content': '这是在离线状态创建的帖子' },
     ),
   );
   ```

3. **手动同步操作**
   ```dart
   await offlineManager.syncPendingOperations();
   ```

4. **缓存数据**
   ```dart
   await offlineManager.cachePostData(posts);
   ```

5. **获取缓存数据**
   ```dart
   final cachedPosts = await offlineManager.getCachedPosts();
   ```

6. **监听同步状态**
   ```dart
   offlineManager.syncStatusStream.listen((status) {
     switch (status) {
       case SyncStatus.syncing:
         // 正在同步
         break;
       case SyncStatus.synced:
         // 同步完成
         break;
       case SyncStatus.failed:
         // 同步失败
         break;
       default:
         break;
     }
   });
   ```

7. **资源释放**
   ```dart
   offlineManager.dispose();
   ```

## 离线状态显示组件

`OfflineStatusWidget` 是一个用户界面组件，用于显示当前网络连接状态和同步进度。它与离线管理器集成，提供以下功能：

- 显示在线/离线状态指示
- 显示待同步操作数量
- 显示上次同步时间
- 提供手动同步按钮

### 使用方法

```dart
Scaffold(
  appBar: AppBar(
    title: Text('我的应用'),
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: OfflineStatusWidget(
          showSyncButton: true,
          showLastSyncTime: true,
        ),
      ),
    ],
  ),
  body: ...
)
```

## 离线功能架构

离线功能采用分层架构实现，确保可扩展性和可维护性：

1. **表示层**：`OfflineStatusWidget` 负责UI展示
2. **管理层**：`OfflineManager` 负责核心逻辑和数据管理
3. **存储层**：使用 `shared_preferences` 进行持久化存储
4. **网络层**：使用 `connectivity_plus` 监测网络状态

## 最佳实践

- 对于需要离线支持的操作，始终使用`addPendingOperation`方法
- 使用`OfflineStatusWidget`组件给用户提供明确的网络状态反馈
- 在应用启动时初始化离线管理器，在退出时释放资源
- 使用`cachePostData`方法缓存关键数据供离线浏览
- 确保同步操作具有幂等性，避免重复提交导致的数据问题
