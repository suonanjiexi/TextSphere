import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'performance_utils.dart';

/// 图像压缩质量级别
enum CompressionLevel {
  /// 低质量压缩
  low,

  /// 中等质量压缩
  medium,

  /// 高质量压缩
  high,

  /// 极高质量压缩
  veryHigh,

  /// 最高质量压缩
  max,
}

/// 图像压缩服务
/// 根据设备性能和使用场景动态调整图像质量和尺寸
class ImageCompressionService {
  /// 私有构造函数，防止实例化
  ImageCompressionService._();

  /// 默认图像压缩质量
  static int get _defaultQuality => PerformanceUtils.isLowEndDevice() ? 70 : 85;

  /// 压缩级别映射到质量值
  static final Map<CompressionLevel, int> _qualityMap = {
    CompressionLevel.low: 50,
    CompressionLevel.medium: 70,
    CompressionLevel.high: 85,
    CompressionLevel.veryHigh: 92,
    CompressionLevel.max: 100,
  };

  /// 压缩图像
  static Future<Uint8List> compressImage(
    File image, {
    CompressionLevel compressionLevel = CompressionLevel.high,
    int? targetWidth,
    int? targetHeight,
    bool maintainAspectRatio = true,
  }) async {
    try {
      // 读取图像文件
      final bytes = await image.readAsBytes();

      // 解码图像
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image uiImage = frameInfo.image;

      // 计算调整大小的尺寸
      final int originalWidth = uiImage.width;
      final int originalHeight = uiImage.height;

      int? width = targetWidth;
      int? height = targetHeight;

      if (maintainAspectRatio && (width != null || height != null)) {
        final double aspectRatio = originalWidth / originalHeight;

        if (width != null && height == null) {
          height = (width / aspectRatio).round();
        } else if (height != null && width == null) {
          width = (height * aspectRatio).round();
        }
      }

      // 如果未指定目标尺寸，则使用原始尺寸
      width ??= originalWidth;
      height ??= originalHeight;

      // 在需要时调整图像大小
      ui.Image resizedImage = uiImage;
      if (width != originalWidth || height != originalHeight) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);

        // 使用最佳过滤质量
        final paint =
            Paint()..filterQuality = PerformanceUtils.getOptimalFilterQuality();

        canvas.drawImageRect(
          uiImage,
          Rect.fromLTWH(
            0,
            0,
            originalWidth.toDouble(),
            originalHeight.toDouble(),
          ),
          Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
          paint,
        );

        final picture = recorder.endRecording();
        resizedImage = await picture.toImage(width, height);
      }

      // 获取压缩质量
      final int quality = _getQualityForLevel(compressionLevel);

      // 将图像编码为字节
      final ByteData? byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      // 释放资源
      if (resizedImage != uiImage) {
        resizedImage.dispose();
      }
      uiImage.dispose();

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      } else {
        throw Exception('Failed to encode image');
      }
    } catch (e) {
      print('Error compressing image: $e');
      // 如果压缩失败，返回原始图像
      return await image.readAsBytes();
    }
  }

  /// 将网络图像压缩为本地缓存文件
  static Future<File?> compressAndCacheNetworkImage(
    String url, {
    CompressionLevel compressionLevel = CompressionLevel.high,
    int? targetWidth,
    int? targetHeight,
  }) async {
    try {
      // 创建唯一的缓存文件名
      final cacheFilename = _generateCacheFilename(url);

      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final cacheFilePath = '${tempDir.path}/$cacheFilename';

      // 检查缓存是否已存在
      final cacheFile = File(cacheFilePath);
      if (await cacheFile.exists()) {
        return cacheFile;
      }

      // 获取网络图像数据
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch image: ${response.statusCode}');
      }

      final bytes = await consolidateHttpClientResponseBytes(response);

      // 将字节写入临时文件
      final tempFile = File('${tempDir.path}/temp_$cacheFilename');
      await tempFile.writeAsBytes(bytes);

      // 压缩图像
      final compressedBytes = await compressImage(
        tempFile,
        compressionLevel: compressionLevel,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );

      // 将压缩后的数据写入缓存文件
      await cacheFile.writeAsBytes(compressedBytes);

      // 删除临时文件
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      return cacheFile;
    } catch (e) {
      print('Error caching network image: $e');
      return null;
    }
  }

  /// 从Widget生成图像
  static Future<Uint8List?> captureWidget(
    Widget widget, {
    Size? logicalSize,
    double pixelRatio = 1.0,
    Duration waitDuration = const Duration(milliseconds: 10),
    CompressionLevel compressionLevel = CompressionLevel.high,
  }) async {
    // 直接抛出暂未实现的异常，此功能需要合适的上下文环境才能工作
    throw UnimplementedError('离屏Widget渲染功能需要有效的BuildContext和适当的测试环境才能实现');
  }

  /// 根据压缩级别获取质量值
  static int _getQualityForLevel(CompressionLevel level) {
    return _qualityMap[level] ?? _defaultQuality;
  }

  /// 为URL生成缓存文件名
  static String _generateCacheFilename(String url) {
    // 使用URL的哈希值作为文件名的一部分
    final hash = url.hashCode.abs();
    // 提取URL中的文件名部分（如果存在）
    final uri = Uri.parse(url);
    final filename =
        uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'image';
    // 如果文件名包含扩展名，则保留它
    final extension = filename.contains('.') ? filename.split('.').last : 'png';

    return 'compressed_${hash}_$filename.$extension';
  }
}
