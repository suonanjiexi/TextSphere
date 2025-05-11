import 'package:flutter_test/flutter_test.dart';
import 'package:text_sphere_app/data/models/post_model.dart';
import 'package:text_sphere_app/utils/offline_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('OfflineManager 测试', () {
    late OfflineManager offlineManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      offlineManager = OfflineManager();
      await offlineManager.init();
    });

    test('缓存和获取帖子数据', () async {
      // 创建测试帖子
      final posts = [
        PostModel(
          id: '1',
          title: '测试帖子1',
          content: '这是测试内容1',
          authorId: 'user1',
          authorName: '测试用户1',
          createdAt: DateTime.now(),
        ),
        PostModel(
          id: '2',
          title: '测试帖子2',
          content: '这是测试内容2',
          authorId: 'user1',
          authorName: '测试用户1',
          createdAt: DateTime.now(),
        ),
      ];

      // 缓存帖子
      await offlineManager.cachePostData(posts);

      // 获取缓存的帖子
      final cachedPosts = await offlineManager.getCachedPosts();

      // 断言
      expect(cachedPosts.length, equals(posts.length));
      expect(cachedPosts[0].id, equals(posts[0].id));
      expect(cachedPosts[1].title, equals(posts[1].title));
    });

    test('添加和同步挂起的操作', () async {
      // 创建挂起操作
      final operation = PendingOperation(
        type: OperationType.create,
        resourceType: ResourceType.post,
        resourceId: 'post1',
        data: {'title': '新帖子', 'content': '新帖子内容'},
      );

      // 添加挂起操作
      await offlineManager.addPendingOperation(operation);

      // 同步操作
      // 注意：这只是测试代码路径，实际同步需要网络请求
      await offlineManager.syncPendingOperations();
    });
  });
}
