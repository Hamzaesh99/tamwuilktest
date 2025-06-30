import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:async/async.dart';

class PerformanceUtils {
  /// تشغيل دالة ثقيلة في Isolate منفصل
  static Future<R> runInBackground<R, P>(
    FutureOr<R> Function(P) function,
    P parameter, {
    String debugLabel = 'background_task',
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await Isolate.run(() => function(parameter));
      
      if (kDebugMode) {
        print('Task "$debugLabel" completed in ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error in background task "$debugLabel": $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// تحسين أداء القوائم الكبيرة باستخدام ListView.builder
  static Widget buildOptimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    Widget? separator,
    EdgeInsets? padding,
    ScrollController? controller,
  }) {
    if (items.isEmpty) {
      return const Center(child: Text('لا توجد عناصر لعرضها'));
    }
    return ListView.separated(
      controller: controller,
      padding: padding,
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
      separatorBuilder: (context, index) => separator ?? const SizedBox.shrink(),
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      cacheExtent: 500,
    );
  }

  /// تحسين أداء الصور
  static ImageProvider optimizeImage(String imagePath, {double? width, double? height}) {
    // استخدام Image.asset مباشرة مع cacheWidth و cacheHeight للأداء الأفضل
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    ).image;
  }

  /// تحميل البيانات الأولية بشكل متوازي
  static Future<List<T>> loadDataInParallel<T>({
    required List<Future<T>> Function() tasks,
    String debugLabel = 'parallel_tasks',
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final results = await Future.wait(tasks());
      
      if (kDebugMode) {
        print('Parallel tasks "$debugLabel" completed in ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return results;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error in parallel tasks "$debugLabel": $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// إلغاء المهام القديمة عند الحاجة
  static CancelableOperation<T> createCancelableOperation<T>(
    Future<T> Function() computation, {
    void Function()? onCancel,
  }) {
    return CancelableOperation<T>.fromFuture(
      computation(),
      onCancel: onCancel,
    );
  }
}
