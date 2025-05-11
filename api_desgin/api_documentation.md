# TextSphere API文档

**重要说明**: 当前应用处于开发阶段，现阶段主要使用本地模拟数据进行功能开发。本文档定义了计划实现的API结构，以供后续开发参考。API客户端(`ApiClient`)已经实现，但实际的网络请求尚未连接到后端服务。

**实现状态**:
- ✅ API客户端框架已实现，包括HTTP请求方法、错误处理和认证
- ⚠️ 目前所有模块使用模拟数据，包括用户、广场、圈子、消息和个人中心模块
- 📝 请参考这份API文档为后端开发提供指导

**API客户端实现**:
- 基于`Dio` HTTP客户端库
- 实现了RESTful API请求方法：GET、POST、PUT、DELETE
- 支持文件上传功能
- 包含请求拦截器，用于添加认证令牌
- 实现了错误处理机制，包括网络错误、服务器错误、认证错误等

**状态管理**:
- 使用BLoC模式管理应用状态和数据流
- 基于Clean Architecture架构，通过Repository层与API交互
- 本地缓存实现使用SharedPreferences

## 应用概述

TextSphere是一个社交文本分享平台，主要功能包括用户社交、内容发布与分享、话题讨论和私聊等。应用由以下几个主要模块组成：

## 模块功能概述

1. **用户模块**：负责用户注册、登录、个人信息管理、关注关系等功能。
2. **广场模块**：为用户提供浏览全平台内容、发布帖子、点赞评论等功能。
3. **圈子模块**：为用户提供基于特定兴趣话题的小型社区，用户可加入感兴趣的圈子并参与讨论。
4. **消息模块**：提供用户间的私信功能，支持一对一聊天。
5. **个人中心模块**：用户管理个人资料、查看自己发布的内容和收到的互动。

## 目录

1. [用户模块](#用户模块)
2. [广场模块](#广场模块)
3. [圈子模块](#圈子模块)
4. [消息模块](#消息模块)
5. [个人中心模块](#个人中心模块)

## 用户模块

### 功能点

- 用户注册
- 用户登录
- 个人信息管理
- 关注/取消关注用户
- 获取关注列表
- 获取粉丝列表
- 用户搜索

### 接口设计

#### 1. 用户登录

**请求**
```
POST /api/user/login
```

**参数**
```json
{
  "username": "string", // 用户名
  "password": "string"  // 密码
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "username": "string",
    "nickname": "string",
    "avatar": "string",
    "token": "string",
    "createdAt": "timestamp",
    "lastLoginAt": "timestamp"
  }
}
```

#### 2. 用户注册

**请求**
```
POST /api/user/register
```

**参数**
```json
{
  "username": "string", // 用户名
  "password": "string", // 密码
  "nickname": "string"  // 昵称
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "username": "string",
    "nickname": "string",
    "avatar": "string",
    "token": "string",
    "createdAt": "timestamp",
    "lastLoginAt": "timestamp"
  }
}
```

#### 3. 获取当前用户信息

**请求**
```
GET /api/user/current
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "username": "string",
    "nickname": "string",
    "avatar": "string",
    "bio": "string",
    "followingCount": "integer",
    "followerCount": "integer",
    "createdAt": "timestamp",
    "lastLoginAt": "timestamp"
  }
}
```

#### 4. 更新用户信息

**请求**
```
PUT /api/user
```

**参数**
```json
{
  "nickname": "string",   // 昵称
  "bio": "string",        // 个人简介
  "avatar": "string"      // 头像URL
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "username": "string",
    "nickname": "string",
    "avatar": "string",
    "bio": "string"
  }
}
```

#### 5. 上传头像

**请求**
```
POST /api/user/avatar
```

**参数**
```
Form-data:
avatar: file // 头像文件
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "avatarUrl": "string"
  }
}
```

#### 6. 搜索用户

**请求**
```
GET /api/user/search?keyword={keyword}&page={page}&pageSize={pageSize}
```

**参数**
- keyword: string - 搜索关键词
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "integer",
    "users": [
      {
        "id": "string",
        "username": "string",
        "nickname": "string",
        "avatar": "string",
        "bio": "string",
        "followingCount": "integer",
        "followerCount": "integer",
        "isFollowed": "boolean"
      }
    ]
  }
}
```

#### 7. 获取关注列表

**请求**
```
GET /api/user/{userId}/followings?page={page}&pageSize={pageSize}
```

**参数**
- userId: string - 用户ID
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "integer",
    "users": [
      {
        "id": "string",
        "username": "string",
        "nickname": "string",
        "avatar": "string",
        "bio": "string",
        "followingCount": "integer",
        "followerCount": "integer",
        "isFollowed": "boolean"
      }
    ]
  }
}
```

#### 8. 获取粉丝列表

**请求**
```
GET /api/user/{userId}/followers?page={page}&pageSize={pageSize}
```

**参数**
- userId: string - 用户ID
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "integer",
    "users": [
      {
        "id": "string",
        "username": "string",
        "nickname": "string",
        "avatar": "string",
        "bio": "string",
        "followingCount": "integer",
        "followerCount": "integer",
        "isFollowed": "boolean"
      }
    ]
  }
}
```

#### 9. 关注用户

**请求**
```
POST /api/user/follow/{userId}
```

**参数**
- userId: string - 要关注的用户ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 10. 取消关注用户

**请求**
```
POST /api/user/unfollow/{userId}
```

**参数**
- userId: string - 要取消关注的用户ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 11. 退出登录

**请求**
```
POST /api/user/logout
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

## 广场模块

### 功能点

- 获取广场帖子列表
- 获取关注用户的帖子列表
- 发布帖子
- 点赞/取消点赞帖子
- 评论帖子
- 回复评论
- 搜索帖子

### 接口设计

#### 1. 获取广场帖子列表

**请求**
```
GET /api/post/square?page={page}&pageSize={pageSize}
```

**参数**
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "integer",
    "posts": [
      {
        "id": "string",
        "userId": "string",
        "username": "string",
        "userAvatar": "string",
        "title": "string",
        "content": "string",
        "images": ["string"],
        "topics": ["string"],
        "likeCount": "integer",
        "commentCount": "integer",
        "shareCount": "integer",
        "isLiked": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    ]
  }
}
```

#### 2. 获取关注用户的帖子列表

**请求**
```
GET /api/post/following?page={page}&pageSize={pageSize}
```

**参数**
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "integer",
    "posts": [
      {
        "id": "string",
        "userId": "string",
        "username": "string",
        "userAvatar": "string",
        "title": "string",
        "content": "string",
        "images": ["string"],
        "topics": ["string"],
        "likeCount": "integer",
        "commentCount": "integer",
        "shareCount": "integer",
        "isLiked": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    ]
  }
}
```

#### 3. 获取帖子详情

**请求**
```
GET /api/post/{postId}
```

**参数**
- postId: string - 帖子ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "userId": "string",
    "username": "string",
    "userAvatar": "string",
    "title": "string",
    "content": "string",
    "images": ["string"],
    "topics": ["string"],
    "likeCount": "integer",
    "commentCount": "integer",
    "shareCount": "integer",
    "isLiked": "boolean",
    "createdAt": "timestamp",
    "updatedAt": "timestamp",
    "comments": [
      {
        "id": "string",
        "userId": "string",
        "username": "string",
        "userAvatar": "string",
        "content": "string",
        "likeCount": "integer",
        "isLiked": "boolean",
        "createdAt": "timestamp",
        "replies": [
          {
            "id": "string",
            "userId": "string",
            "username": "string",
            "userAvatar": "string",
            "content": "string",
            "likeCount": "integer",
            "isLiked": "boolean",
            "replyToUserId": "string",
            "replyToUsername": "string",
            "createdAt": "timestamp"
          }
        ]
      }
    ]
  }
}
```

#### 4. 发布帖子

**请求**
```
POST /api/post
```

**参数**
```json
{
  "title": "string",       // 标题
  "content": "string",     // 内容
  "images": ["string"],    // 图片URL列表
  "topics": ["string"]     // 话题列表
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "userId": "string",
    "username": "string",
    "userAvatar": "string",
    "title": "string",
    "content": "string",
    "images": ["string"],
    "topics": ["string"],
    "likeCount": 0,
    "commentCount": 0,
    "shareCount": 0,
    "isLiked": false,
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  }
}
```

#### 5. 上传图片

**请求**
```
POST /api/post/image
```

**参数**
```
Form-data:
image: file // 图片文件
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "imageUrl": "string"
  }
}
```

#### 6. 点赞帖子

**请求**
```
POST /api/post/{postId}/like
```

**参数**
- postId: string - 帖子ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true,
    "likeCount": "integer"
  }
}
```

#### 7. 取消点赞帖子

**请求**
```
POST /api/post/{postId}/unlike
```

**参数**
- postId: string - 帖子ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true,
    "likeCount": "integer"
  }
}
```

#### 8. 评论帖子

**请求**
```
POST /api/post/{postId}/comment
```

**参数**
```json
{
  "content": "string"    // 评论内容
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "userId": "string",
    "username": "string",
    "userAvatar": "string",
    "content": "string",
    "likeCount": 0,
    "isLiked": false,
    "createdAt": "timestamp"
  }
}
```

#### 9. 回复评论

**请求**
```
POST /api/post/comment/{commentId}/reply
```

**参数**
```json
{
  "content": "string",             // 回复内容
  "replyToUserId": "string"        // 被回复用户ID
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "userId": "string",
    "username": "string",
    "userAvatar": "string",
    "content": "string",
    "likeCount": 0,
    "isLiked": false,
    "replyToUserId": "string",
    "replyToUsername": "string",
    "createdAt": "timestamp"
  }
}
```

#### 10. 点赞评论

**请求**
```
POST /api/post/comment/{commentId}/like
```

**参数**
- commentId: string - 评论ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true,
    "likeCount": "integer"
  }
}
```

#### 11. 取消点赞评论

**请求**
```
POST /api/post/comment/{commentId}/unlike
```

**参数**
- commentId: string - 评论ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true,
    "likeCount": "integer"
  }
}
```

#### 12. 搜索帖子

**请求**
```
GET /api/post/search?keyword={keyword}&page={page}&pageSize={pageSize}
```

**参数**
- keyword: string - 搜索关键词
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "total": "integer",
    "posts": [
      {
        "id": "string",
        "userId": "string",
        "username": "string",
        "userAvatar": "string",
        "title": "string",
        "content": "string",
        "images": ["string"],
        "topics": ["string"],
        "likeCount": "integer",
        "commentCount": "integer",
        "shareCount": "integer",
        "isLiked": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    ]
  }
}
```

## 圈子模块

### 功能点

- 获取推荐圈子列表
- 获取已加入圈子列表
- 获取圈子分类列表
- 搜索圈子
- 获取圈子详情
- 加入/退出圈子
- 发布圈子帖子
- 圈子内查看帖子

### 接口设计

#### 1. 获取推荐圈子列表

**请求**
```
GET /api/circle/recommend
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "circles": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "avatar": "string",
        "cover": "string",
        "memberCount": "integer",
        "postCount": "integer",
        "category": "string",
        "isRecommended": true,
        "isJoined": "boolean",
        "createdAt": "timestamp"
      }
    ]
  }
}
```

#### 2. 获取已加入圈子列表

**请求**
```
GET /api/circle/joined
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "circles": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "avatar": "string",
        "cover": "string",
        "memberCount": "integer",
        "postCount": "integer",
        "category": "string",
        "isRecommended": "boolean",
        "isJoined": true,
        "createdAt": "timestamp"
      }
    ]
  }
}
```

#### 3. 获取特定类别的圈子列表

**请求**
```
GET /api/circle/category/{category}
```

**参数**
- category: string - 圈子类别

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "circles": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "avatar": "string",
        "cover": "string",
        "memberCount": "integer",
        "postCount": "integer",
        "category": "string",
        "isRecommended": "boolean",
        "isJoined": "boolean",
        "createdAt": "timestamp"
      }
    ]
  }
}
```

#### 4. 搜索圈子

**请求**
```
GET /api/circle/search?keyword={keyword}
```

**参数**
- keyword: string - 搜索关键词

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "circles": [
      {
        "id": "string",
        "name": "string",
        "description": "string",
        "avatar": "string",
        "cover": "string",
        "memberCount": "integer",
        "postCount": "integer",
        "category": "string",
        "isRecommended": "boolean",
        "isJoined": "boolean",
        "createdAt": "timestamp"
      }
    ]
  }
}
```

#### 5. 获取圈子详情

**请求**
```
GET /api/circle/{circleId}
```

**参数**
- circleId: string - 圈子ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "name": "string",
    "description": "string",
    "avatar": "string",
    "cover": "string",
    "memberCount": "integer",
    "postCount": "integer",
    "category": "string",
    "isRecommended": "boolean",
    "isJoined": "boolean",
    "createdAt": "timestamp",
    "posts": [
      {
        "id": "string",
        "userId": "string",
        "username": "string",
        "userAvatar": "string",
        "content": "string",
        "images": ["string"],
        "likeCount": "integer",
        "commentCount": "integer",
        "isLiked": "boolean",
        "createdAt": "timestamp"
      }
    ]
  }
}
```

#### 6. 加入圈子

**请求**
```
POST /api/circle/{circleId}/join
```

**参数**
- circleId: string - 圈子ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 7. 退出圈子

**请求**
```
POST /api/circle/{circleId}/leave
```

**参数**
- circleId: string - 圈子ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 8. 发布圈子帖子

**请求**
```
POST /api/circle/{circleId}/post
```

**参数**
```json
{
  "content": "string",    // 内容
  "images": ["string"]    // 图片URL列表
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "userId": "string",
    "username": "string",
    "userAvatar": "string",
    "content": "string",
    "images": ["string"],
    "likeCount": 0,
    "commentCount": 0,
    "isLiked": false,
    "createdAt": "timestamp"
  }
}
```

## 消息模块

### 功能点

- 获取会话列表
- 获取会话消息
- 发送消息
- 创建会话
- 消息状态管理
- 会话操作

### 接口设计

#### 1. 获取会话列表

**请求**
```
GET /api/message/conversations
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "conversations": [
      {
        "id": "string",
        "name": "string",
        "avatar": "string",
        "lastMessage": {
          "id": "string",
          "content": "string",
          "type": "text|image",
          "senderId": "string",
          "senderName": "string",
          "createdAt": "timestamp"
        },
        "unreadCount": "integer",
        "lastMessageTime": "timestamp",
        "participantIds": ["string"],
        "type": "single|group"
      }
    ]
  }
}
```

#### 2. 获取会话消息

**请求**
```
GET /api/message/conversations/{conversationId}/messages?page={page}&pageSize={pageSize}
```

**参数**
- conversationId: string - 会话ID
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "messages": [
      {
        "id": "string",
        "conversationId": "string",
        "senderId": "string",
        "senderName": "string",
        "senderAvatar": "string",
        "content": "string",
        "type": "text|image",
        "status": "sent|delivered|read",
        "createdAt": "timestamp"
      }
    ]
  }
}
```

#### 3. 发送消息

**请求**
```
POST /api/message/conversations/{conversationId}/messages
```

**参数**
```json
{
  "content": "string",  // 消息内容
  "type": "text|image"  // 消息类型
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "conversationId": "string",
    "senderId": "string",
    "senderName": "string",
    "senderAvatar": "string",
    "content": "string",
    "type": "text|image",
    "status": "sent",
    "createdAt": "timestamp"
  }
}
```

#### 4. 创建会话

**请求**
```
POST /api/message/conversations
```

**参数**
```json
{
  "receiverId": "string",    // 接收者ID
  "type": "single|group"     // 会话类型
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "string",
    "name": "string",
    "avatar": "string",
    "lastMessage": null,
    "unreadCount": 0,
    "lastMessageTime": "timestamp",
    "participantIds": ["string"],
    "type": "single|group"
  }
}
```

#### 5. 标记消息为已读

**请求**
```
POST /api/message/messages/{messageId}/read
```

**参数**
- messageId: string - 消息ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 6. 标记会话所有消息为已读

**请求**
```
POST /api/message/conversations/{conversationId}/read
```

**参数**
- conversationId: string - 会话ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 7. 删除消息

**请求**
```
DELETE /api/message/messages/{messageId}
```

**参数**
- messageId: string - 消息ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 8. 删除会话

**请求**
```
DELETE /api/message/conversations/{conversationId}
```

**参数**
- conversationId: string - 会话ID

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 9. 置顶/取消置顶会话

**请求**
```
POST /api/message/conversations/{conversationId}/pin
```

**参数**
- conversationId: string - 会话ID
```json
{
  "isPinned": true|false  // 是否置顶
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 10. 静音/取消静音会话

**请求**
```
POST /api/message/conversations/{conversationId}/mute
```

**参数**
- conversationId: string - 会话ID
```json
{
  "isMuted": true|false  // 是否静音
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "success": true
  }
}
```

#### 11. 获取未读消息数

**请求**
```
GET /api/message/unread
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "count": "integer"
  }
}
```

## 个人中心模块

### 功能点

- 获取个人信息
- 获取用户发布的帖子
- 获取用户点赞的帖子
- 获取用户关注的人
- 获取用户的粉丝
- 系统设置管理

### 接口设计

#### 1. 获取用户发布的帖子

**请求**
```
GET /api/user/{userId}/posts?page={page}&pageSize={pageSize}
```

**参数**
- userId: string - 用户ID
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "posts": [
      {
        "id": "string",
        "userId": "string",
        "username": "string",
        "userAvatar": "string",
        "title": "string",
        "content": "string",
        "images": ["string"],
        "topics": ["string"],
        "likeCount": "integer",
        "commentCount": "integer",
        "shareCount": "integer",
        "isLiked": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    ],
    "total": "integer",
    "hasMore": "boolean"
  }
}
```

#### 2. 获取用户点赞的帖子

**请求**
```
GET /api/user/{userId}/liked-posts?page={page}&pageSize={pageSize}
```

**参数**
- userId: string - 用户ID
- page: integer - 页码，默认1
- pageSize: integer - 每页数量，默认20

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "posts": [
      {
        "id": "string",
        "userId": "string",
        "username": "string",
        "userAvatar": "string",
        "title": "string",
        "content": "string",
        "images": ["string"],
        "topics": ["string"],
        "likeCount": "integer",
        "commentCount": "integer",
        "shareCount": "integer",
        "isLiked": "boolean",
        "createdAt": "timestamp",
        "updatedAt": "timestamp"
      }
    ],
    "total": "integer",
    "hasMore": "boolean"
  }
}
```

## 离线功能模块

离线功能模块负责管理客户端的离线数据存储和同步策略，以支持用户在无网络或弱网络环境下的使用体验。

### 功能点

- 获取缓存策略配置
- 同步离线操作
- 获取同步状态
- 检查资源更新状态

### 接口设计

#### 1. 获取缓存策略配置

**请求**
```
GET /api/config/offline-cache
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "cacheEnabled": true,
    "resourceMaxAge": {
      "posts": 3600,      // 帖子缓存有效期，单位秒
      "comments": 1800,   // 评论缓存有效期，单位秒
      "profiles": 7200,   // 用户资料缓存有效期，单位秒
      "circles": 86400    // 圈子缓存有效期，单位秒
    },
    "maxCacheSize": 50000000,  // 最大缓存大小，单位字节
    "priorityResources": [
      "posts",            // 优先缓存的资源类型
      "user_profile"
    ],
    "syncFrequency": 900, // 自动同步频率，单位秒
    "compressionEnabled": true
  }
}
```

#### 2. 同步离线操作

**请求**
```
POST /api/sync/operations
```

**参数**
```json
{
  "operations": [
    {
      "id": "string",          // 客户端生成的操作ID
      "type": "create",        // 操作类型：create, update, delete
      "resourceType": "post",  // 资源类型：post, comment, user, message
      "resourceId": "string",  // 资源ID，对于create操作可能是临时ID
      "data": {                // 操作数据
        "key": "value"
      },
      "createdAt": "timestamp" // 操作创建时间
    }
  ],
  "deviceId": "string",        // 设备标识
  "lastSyncTime": "timestamp"  // 上次同步时间
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "results": [
      {
        "clientOperationId": "string",  // 客户端操作ID
        "serverId": "string",          // 服务器资源ID
        "success": true,               // 操作是否成功
        "error": null,                 // 错误信息
        "timestamp": "timestamp"       // 操作时间戳
      }
    ],
    "syncTime": "timestamp",          // 本次同步时间
    "nextSyncAfter": 900              // 建议下次同步间隔，单位秒
  }
}
```

#### 3. 获取资源更新状态

**请求**
```
POST /api/sync/check-updates
```

**参数**
```json
{
  "resources": [
    {
      "type": "post",          // 资源类型
      "id": "string",          // 资源ID
      "version": "string",     // 资源版本，如果有
      "lastFetchTime": "timestamp" // 上次获取时间
    }
  ]
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "updates": [
      {
        "type": "post",
        "id": "string",
        "hasChanged": true,   // 资源是否有更新
        "currentVersion": "string", // 当前版本
        "lastModified": "timestamp" // 最后修改时间
      }
    ]
  }
}
```

#### 4. 批量获取资源

**请求**
```
POST /api/sync/batch-resources
```

**参数**
```json
{
  "resources": [
    {
      "type": "post",    // 资源类型
      "id": "string"     // 资源ID
    }
  ]
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "resources": {
      "posts": {
        "post_id_1": {
          // 完整的post对象数据
        },
        "post_id_2": {
          // 完整的post对象数据
        }
      },
      "users": {
        "user_id_1": {
          // 完整的user对象数据
        }
      }
      // 其他资源类型...
    }
  }
}
```

#### 5. 设置同步状态

**请求**
```
POST /api/sync/status
```

**参数**
```json
{
  "deviceId": "string",
  "lastSyncTime": "timestamp",
  "pendingOperationsCount": 0,
  "syncStatus": "completed"  // completed, in_progress, failed
}
```

**响应**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "acknowledged": true
  }
}
```

### 离线管理器实现说明

客户端的离线管理系统通过OfflineManager类实现，主要功能包括：

1. **网络状态监测**：使用connectivity_plus库监听设备网络连接变化
2. **操作队列管理**：缓存离线操作，等待在线时同步
3. **数据缓存**：本地存储常用数据，减少网络请求
4. **自动同步**：联网后自动同步待处理操作
5. **冲突解决**：处理线上线下数据冲突

以上API设计旨在支持这些功能，使移动客户端能够在各种网络条件下提供良好的用户体验。

## 后续开发建议

以下是从模拟数据过渡到实际API实现的建议步骤：

1. **API服务器开发**：
   - 根据本文档定义的接口规范开发后端API服务
   - 实现必要的身份验证和授权机制
   - 确保API响应的数据结构与本文档中的定义一致

2. **前端集成**：
   - 移除模拟数据层，保留现有的Repository和UseCase结构
   - 更新RemoteDataSource实现，使用已实现的ApiClient类连接实际的后端服务
   - 确保错误处理机制正确捕获和处理API错误

3. **数据模型更新**：
   - 确保所有Model类的fromJson和toJson方法与后端返回的JSON结构匹配
   - 添加必要的数据验证逻辑

4. **API测试**：
   - 为每个API端点编写集成测试，确保前后端正确通信
   - 测试各种错误情况和边界条件

5. **本地数据缓存**：
   - 完善LocalDataSource实现，在适当的情况下缓存API响应
   - 实现离线模式支持

本API文档将持续更新，以反映应用功能的变化和后端API的演进。 