# TextSphere App 项目结构

本文档详细说明了TextSphere App的项目结构，包括所有目录和主要文件的功能描述。

## 项目总览

TextSphere App是一款基于Flutter开发的文字社交应用，采用Clean Architecture架构，将应用分为表示层、领域层和数据层。

## 目录结构

```
lib/                           # 应用主目录
├── main.dart                  # 应用入口点和初始化
├── components/                # 可复用UI组件目录
│   ├── app_avatar.dart        # 用户头像组件
│   ├── chat_list_item.dart    # 聊天列表项组件
│   ├── offline_status_widget.dart  # 离线状态提示组件
│   ├── optimized_list.dart    # 优化的列表组件，支持懒加载和虚拟滚动
│   ├── post_card.dart         # 帖子卡片组件
│   └── membership/            # 会员相关组件
├── core/                      # 核心功能和配置
│   ├── auth/                  # 认证相关核心功能
│   ├── cache/                 # 缓存管理
│   ├── di/                    # 依赖注入配置
│   ├── error/                 # 错误处理
│   ├── network/               # 网络相关配置
│   ├── router/                # 路由配置
│   ├── routes/                # 路由定义
│   ├── theme/                 # 应用主题配置
│   └── README.md              # 核心模块说明文档
├── data/                      # 数据层
│   ├── datasources/           # 数据源(本地和远程)
│   ├── models/                # 数据模型(DTOs)
│   └── repositories/          # 仓库实现
├── domain/                    # 领域层
│   ├── entities/              # 业务实体
│   ├── repositories/          # 仓库接口
│   └── usecases/              # 用例实现
├── models/                    # 公共模型
│   ├── circle_model.dart      # 圈子模型
│   └── membership_model.dart  # 会员模型
├── presentation/              # 表示层
│   ├── blocs/                 # Bloc状态管理
│   │   ├── auth/              # 认证相关状态管理
│   │   │   ├── auth_bloc.dart    # 认证Bloc实现
│   │   │   ├── auth_event.dart   # 认证事件定义
│   │   │   └── auth_state.dart   # 认证状态定义
│   │   ├── chat/              # 聊天相关状态管理
│   │   │   ├── chat_bloc.dart    # 聊天Bloc实现 
│   │   │   ├── chat_event.dart   # 聊天事件定义
│   │   │   └── chat_state.dart   # 聊天状态定义
│   │   ├── circle/            # 圈子相关状态管理
│   │   │   ├── circle_bloc.dart  # 圈子Bloc实现
│   │   │   ├── circle_event.dart # 圈子事件定义
│   │   │   └── circle_state.dart # 圈子状态定义
│   │   ├── post_detail/       # 帖子详情相关状态管理
│   │   │   ├── post_detail_bloc.dart  # 帖子详情Bloc实现
│   │   │   ├── post_detail_event.dart # 帖子详情事件定义
│   │   │   └── post_detail_state.dart # 帖子详情状态定义
│   │   ├── square/            # 广场相关状态管理
│   │   │   ├── square_bloc.dart         # 广场Bloc实现
│   │   │   ├── square_event.dart        # 广场事件定义
│   │   │   ├── square_state.dart        # 广场状态定义
│   │   │   ├── square_search_bloc.dart  # 广场搜索Bloc实现
│   │   │   ├── square_search_event.dart # 广场搜索事件定义
│   │   │   └── square_search_state.dart # 广场搜索状态定义
│   │   ├── theme/             # 主题相关状态管理
│   │   │   ├── theme_bloc.dart  # 主题Bloc实现
│   │   │   ├── theme_event.dart # 主题事件定义
│   │   │   └── theme_state.dart # 主题状态定义
│   │   └── user_search/       # 用户搜索相关状态管理
│   │       ├── user_search_bloc.dart  # 用户搜索Bloc实现
│   │       ├── user_search_event.dart # 用户搜索事件定义
│   │       └── user_search_state.dart # 用户搜索状态定义
│   ├── pages/                 # 应用页面
│   │   ├── auth/              # 认证相关页面
│   │   │   └── login_page.dart  # 登录页面
│   │   ├── membership/        # 会员相关页面
│   │   │   └── membership_page.dart # 会员页面
│   │   ├── home_page.dart            # 首页
│   │   ├── settings_page.dart        # 设置页面
│   │   ├── profile_page.dart         # 个人资料页面
│   │   ├── chat_detail_page.dart     # 聊天详情页面
│   │   ├── message_list_page.dart    # 消息列表页面
│   │   ├── circle_page.dart          # 圈子页面
│   │   ├── circle_detail_page.dart   # 圈子详情页面
│   │   ├── square_page.dart          # 广场页面
│   │   ├── square_detail_page.dart   # 广场详情页面
│   │   ├── square_search_page.dart   # 广场搜索页面
│   │   ├── followers_page.dart       # 粉丝页面
│   │   ├── following_page.dart       # 关注页面
│   │   ├── notification_list_page.dart # 通知列表页面
│   │   ├── post_detail_page.dart     # 帖子详情页面
│   │   ├── circle_create_page.dart   # 创建圈子页面
│   │   ├── login_page.dart           # 登录页面
│   │   ├── register_page.dart        # 注册页面
│   │   ├── square_post_create_page.dart # 创建广场帖子页面
│   │   ├── user_search_page.dart     # 用户搜索页面
│   │   ├── circle_post_create_page.dart # 创建圈子帖子页面
│   │   ├── following_search_page.dart # 关注搜索页面
│   │   └── followers_search_page.dart # 粉丝搜索页面
│   └── widgets/               # UI组件
│       ├── optimized_list.dart       # 优化列表组件
│       ├── app_network_image.dart    # 网络图片组件
│       ├── error_page.dart           # 错误页面组件
│       ├── app_avatar.dart           # 头像组件
│       ├── chat_message_bubble.dart  # 聊天气泡组件
│       ├── app_loading_indicator.dart # 加载指示器组件
│       ├── app_card.dart             # 卡片组件
│       ├── app_button.dart           # 按钮组件
│       ├── animated_button.dart      # 动画按钮组件
│       ├── skeleton_loading.dart     # 骨架屏加载组件
│       ├── circle_list_item.dart     # 圈子列表项组件
│       ├── loading_indicator.dart    # 加载指示器组件
│       ├── error_view.dart           # 错误视图组件
│       └── app_text_field.dart       # 文本输入框组件
└── utils/                     # 工具类
    ├── analytics/             # 分析工具
    ├── app_layout.dart        # 布局工具
    ├── app_logger.dart        # 日志工具
    ├── app_resources.dart     # 资源管理工具
    ├── app_startup_manager.dart  # 应用启动管理
    ├── app_theme.dart         # 主题工具
    ├── bloc_logger.dart       # Bloc日志工具
    ├── exception_wrapper.dart # 异常处理工具
    ├── image_compression_service.dart  # 图片压缩服务
    ├── lazy_bloc_provider.dart # 懒加载Bloc提供者
    ├── memory_manager.dart     # 内存管理工具
    ├── network_manager.dart    # 网络管理工具
    ├── network_monitor.dart    # 网络监控工具
    ├── null_safety_utils.dart  # 空安全工具
    ├── object_pool.dart        # 对象池实现
    ├── offline_manager.dart    # 离线功能管理
    ├── offline_manager_test.dart # 离线管理测试
    ├── performance_utils.dart  # 性能优化工具
    ├── responsive_util.dart    # 响应式布局工具
    ├── responsive_utils.dart   # 响应式工具
    ├── secure_storage.dart     # 安全存储工具
    ├── strategic_image_cache.dart # 图片缓存策略
    └── widget_lifecycle_mixin.dart # 组件生命周期混入

assets/                        # 应用资源
├── fonts/                     # 字体文件
├── icons/                     # 图标文件
└── images/                    # 图片资源

pubspec.yaml                   # 项目依赖配置文件
pubspec.lock                   # 依赖锁定文件
README.md                      # 项目说明文档
analysis_options.yaml          # 静态分析配置
.env                           # 环境变量文件
.env.example                   # 环境变量示例文件
```

## 模块说明

### 核心模块 (lib/core/)

核心模块包含应用的基础设施和配置，与业务逻辑无关的通用功能。

- **auth/**: 认证相关功能，包括用户认证状态管理和认证API
- **cache/**: 缓存管理，负责应用数据的本地缓存策略
- **di/**: 依赖注入配置，使用get_it实现服务定位和依赖管理
- **error/**: 错误处理，包括异常定义和全局错误处理策略
- **network/**: 网络相关配置，包括API客户端、拦截器和请求/响应处理
- **router/**: 路由配置，使用go_router定义应用的导航结构
- **routes/**: 路由定义，包含所有页面路由的常量定义
- **theme/**: 应用主题配置，定义应用的视觉风格和主题切换

### 领域层 (lib/domain/)

领域层是应用的业务核心，包含业务实体、用例和仓库接口。

- **entities/**: 业务实体，表示应用的核心业务概念
  - conversation.dart: 会话实体
  - circle_post.dart: 圈子帖子实体
  - circle_post_details.dart: 圈子帖子详情实体
  - 其他业务实体...
- **repositories/**: 仓库接口，定义领域层与数据层之间的契约
  - circle_repository.dart: 圈子仓库接口
  - 其他仓库接口...
- **usecases/**: 用例实现，封装特定的业务逻辑
  - message/send_message_usecase.dart: 发送消息用例
  - 其他用例...

### 数据层 (lib/data/)

数据层负责数据获取和持久化，实现领域层定义的仓库接口。

- **datasources/**: 数据源，包括本地和远程数据源
  - circle/circle_local_data_source.dart: 圈子本地数据源
  - 其他数据源...
- **models/**: 数据模型，数据传输对象(DTOs)
- **repositories/**: 仓库实现，实现领域层定义的仓库接口

### 表示层 (lib/presentation/)

表示层负责UI展示和用户交互，使用BLoC模式管理状态。

- **blocs/**: Bloc状态管理，处理UI状态和业务逻辑
  - **auth/**: 认证相关的状态管理
    - auth_bloc.dart: 认证Bloc实现
    - auth_state.dart: 认证状态定义
    - auth_event.dart: 认证事件定义
  - **chat/**: 聊天相关的状态管理
    - chat_bloc.dart: 聊天Bloc实现
    - chat_state.dart: 聊天状态定义
    - chat_event.dart: 聊天事件定义
  - **circle/**: 圈子相关的状态管理
    - circle_bloc.dart: 圈子Bloc实现
    - circle_state.dart: 圈子状态定义
    - circle_event.dart: 圈子事件定义
  - **post_detail/**: 帖子详情相关的状态管理
    - post_detail_bloc.dart: 帖子详情Bloc实现
    - post_detail_state.dart: 帖子详情状态定义
    - post_detail_event.dart: 帖子详情事件定义
  - **square/**: 广场相关的状态管理
    - square_bloc.dart: 广场Bloc实现
    - square_search_bloc.dart: 广场搜索Bloc实现
    - square_state.dart: 广场状态定义
    - square_event.dart: 广场事件定义
    - square_search_state.dart: 广场搜索状态定义
    - square_search_event.dart: 广场搜索事件定义
  - **theme/**: 主题相关的状态管理
    - theme_bloc.dart: 主题Bloc实现
    - theme_state.dart: 主题状态定义
    - theme_event.dart: 主题事件定义
  - **user_search/**: 用户搜索相关的状态管理
    - user_search_bloc.dart: 用户搜索Bloc实现
    - user_search_state.dart: 用户搜索状态定义
    - user_search_event.dart: 用户搜索事件定义
- **pages/**: 应用页面，应用的各个屏幕
  - **auth/**: 认证相关页面
    - login_page.dart: 登录页面
  - **membership/**: 会员相关页面
    - membership_page.dart: 会员页面
  - home_page.dart: 首页
  - settings_page.dart: 设置页面
  - profile_page.dart: 个人资料页面
  - chat_detail_page.dart: 聊天详情页面
  - message_list_page.dart: 消息列表页面
  - circle_page.dart: 圈子页面
  - circle_detail_page.dart: 圈子详情页面
  - square_page.dart: 广场页面
  - square_detail_page.dart: 广场详情页面
  - square_search_page.dart: 广场搜索页面
  - followers_page.dart: 粉丝页面
  - following_page.dart: 关注页面
  - notification_list_page.dart: 通知列表页面
  - post_detail_page.dart: 帖子详情页面
  - circle_create_page.dart: 创建圈子页面
  - login_page.dart: 登录页面
  - register_page.dart: 注册页面
  - square_post_create_page.dart: 创建广场帖子页面
  - user_search_page.dart: 用户搜索页面
  - circle_post_create_page.dart: 创建圈子帖子页面
  - following_search_page.dart: 关注搜索页面
  - followers_search_page.dart: 粉丝搜索页面
- **widgets/**: UI组件，可在不同页面复用的UI元素
  - optimized_list.dart: 优化列表组件
  - app_network_image.dart: 网络图片组件
  - error_page.dart: 错误页面组件
  - app_avatar.dart: 头像组件
  - chat_message_bubble.dart: 聊天气泡组件
  - app_loading_indicator.dart: 加载指示器组件
  - app_card.dart: 卡片组件
  - app_button.dart: 按钮组件
  - animated_button.dart: 动画按钮组件
  - skeleton_loading.dart: 骨架屏加载组件
  - circle_list_item.dart: 圈子列表项组件
  - loading_indicator.dart: 加载指示器组件
  - error_view.dart: 错误视图组件
  - app_text_field.dart: 文本输入框组件

### 组件 (lib/components/)

组件目录包含应用中可复用的UI组件。

- **app_avatar.dart**: 用户头像组件，支持不同大小和样式
- **chat_list_item.dart**: 聊天列表项组件，用于显示会话列表项
- **offline_status_widget.dart**: 离线状态提示组件，显示应用当前的网络状态
- **optimized_list.dart**: 优化的列表组件，支持高效的数据加载和显示
- **post_card.dart**: 帖子卡片组件，用于显示帖子内容和互动
- **membership/**: 会员相关组件，处理会员功能的UI

### 工具类 (lib/utils/)

工具类目录包含各种辅助功能和工具函数。

- **analytics/**: 分析工具，用于用户行为跟踪和应用性能监控
- **app_layout.dart**: 布局工具，提供常用的布局常量和函数
- **app_logger.dart**: 日志工具，统一的日志记录系统
- **app_resources.dart**: 资源管理工具，集中管理应用资源
- **app_startup_manager.dart**: 应用启动管理，处理应用初始化逻辑
- **app_theme.dart**: 主题工具，主题相关的辅助函数
- **bloc_logger.dart**: Bloc日志工具，用于调试Bloc状态变化
- **exception_wrapper.dart**: 异常处理工具，统一的异常捕获和处理
- **image_compression_service.dart**: 图片压缩服务，优化图片上传和显示
- **lazy_bloc_provider.dart**: 懒加载Bloc提供者，提高性能
- **memory_manager.dart**: 内存管理工具，监控和优化应用内存使用
- **network_manager.dart**: 网络管理工具，管理网络请求和响应
- **network_monitor.dart**: 网络监控工具，监测网络连接状态
- **null_safety_utils.dart**: 空安全工具，辅助处理空值情况
- **object_pool.dart**: 对象池实现，重用对象以提高性能
- **offline_manager.dart**: 离线功能管理，处理应用离线状态下的数据同步
- **offline_manager_test.dart**: 离线管理测试文件
- **performance_utils.dart**: 性能优化工具，提供性能监测和优化函数
- **responsive_util.dart**: 响应式布局工具，适配不同尺寸屏幕
- **responsive_utils.dart**: 响应式工具，辅助响应式设计
- **secure_storage.dart**: 安全存储工具，安全地存储敏感信息
- **strategic_image_cache.dart**: 图片缓存策略，优化图片加载和缓存
- **widget_lifecycle_mixin.dart**: 组件生命周期混入，辅助管理Widget生命周期

### 模型 (lib/models/)

模型目录包含应用中使用的公共数据模型。

- **circle_model.dart**: 圈子模型，定义圈子的数据结构
- **membership_model.dart**: 会员模型，定义会员相关的数据结构

### 主文件 (lib/main.dart)

应用的入口点，负责初始化应用、依赖注入、主题设置和路由配置。

## 资源目录 (assets/)

资源目录包含应用使用的非代码资源。

- **fonts/**: 字体文件，应用使用的自定义字体
- **icons/**: 图标文件，应用使用的自定义图标
- **images/**: 图片资源，应用使用的静态图片

## 配置文件

- **pubspec.yaml**: 项目依赖配置文件，定义应用依赖的包和资源
- **pubspec.lock**: 依赖锁定文件，确保依赖版本一致
- **README.md**: 项目说明文档，提供项目概述和使用说明
- **analysis_options.yaml**: 静态分析配置，定义代码质量规则
- **.env**: 环境变量文件，包含应用运行时的配置变量
- **.env.example**: 环境变量示例文件，提供环境变量的示例和说明 