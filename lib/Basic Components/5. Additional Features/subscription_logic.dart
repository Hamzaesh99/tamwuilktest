import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum SubscriptionType {
  free,
  basic,
  premium,
  enterprise
}

enum SubscriptionDuration {
  monthly,
  yearly
}

class SubscriptionLogic {
  final supabase = Supabase.instance.client;
  
  // ÇáÊÍÞÞ ãä ÍÇáÉ ÇáÇÔÊÑÇß ÇáÍÇáí
  Future<Map<String, dynamic>> getCurrentSubscription(String userId) async {
    try {
      final response = await supabase
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÌáÈ ÈíÇäÇÊ ÇáÇÔÊÑÇß: $e');
      return {};
    }
  }

  // ÅäÔÇÁ ÇÔÊÑÇß ÌÏíÏ
  Future<bool> createSubscription({
    required String userId,
    required SubscriptionType type,
    required SubscriptionDuration duration,
    required double amount,
  }) async {
    try {
      await supabase.from('subscriptions').insert({
        'user_id': userId,
        'type': type.toString(),
        'duration': duration.toString(),
        'amount': amount,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': _calculateEndDate(duration),
        'status': 'active',
      });
      return true;
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÅäÔÇÁ ÇáÇÔÊÑÇß: $e');
      return false;
    }
  }

  // ÊÌÏíÏ ÇáÇÔÊÑÇß
  Future<bool> renewSubscription(String subscriptionId) async {
    try {
      final subscription = await supabase
          .from('subscriptions')
          .select()
          .eq('id', subscriptionId)
          .single();
      
      final newEndDate = _calculateEndDate(
        SubscriptionDuration.values.firstWhere(
          (d) => d.toString() == subscription['duration'],
        ),
        startDate: DateTime.parse(subscription['end_date']),
      );

      await supabase
          .from('subscriptions')
          .update({'end_date': newEndDate})
          .eq('id', subscriptionId);
      
      return true;
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÊÌÏíÏ ÇáÇÔÊÑÇß: $e');
      return false;
    }
  }

  // ÅáÛÇÁ ÇáÇÔÊÑÇß
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      await supabase
          .from('subscriptions')
          .update({'status': 'cancelled'})
          .eq('id', subscriptionId);
      return true;
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÅáÛÇÁ ÇáÇÔÊÑÇß: $e');
      return false;
    }
  }

  // ÇáÊÍÞÞ ãä ÕáÇÍíÉ ÇáÇÔÊÑÇß
  Future<bool> isSubscriptionValid(String userId) async {
    try {
      final subscription = await getCurrentSubscription(userId);
      if (subscription.isEmpty) return false;

      final endDate = DateTime.parse(subscription['end_date']);
      final isValid = endDate.isAfter(DateTime.now()) && 
                     subscription['status'] == 'active';
      
      return isValid;
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÇáÊÍÞÞ ãä ÕáÇÍíÉ ÇáÇÔÊÑÇß: $e');
      return false;
    }
  }

  // ÍÓÇÈ ÊÇÑíÎ ÇäÊåÇÁ ÇáÇÔÊÑÇß
  String _calculateEndDate(
    SubscriptionDuration duration, {
    DateTime? startDate,
  }) {
    final start = startDate ?? DateTime.now();
    switch (duration) {
      case SubscriptionDuration.monthly:
        return start.add(const Duration(days: 30)).toIso8601String();
      case SubscriptionDuration.yearly:
        return start.add(const Duration(days: 365)).toIso8601String();
    }
  }

  // ÇáÍÕæá Úáì ããíÒÇÊ ÇáÇÔÊÑÇß
  Map<String, dynamic> getSubscriptionFeatures(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.free:
        return {
          'max_projects': 2,
          'max_team_members': 1,
          'advanced_analytics': false,
          'priority_support': false,
        };
      case SubscriptionType.basic:
        return {
          'max_projects': 5,
          'max_team_members': 3,
          'advanced_analytics': false,
          'priority_support': false,
        };
      case SubscriptionType.premium:
        return {
          'max_projects': 15,
          'max_team_members': 10,
          'advanced_analytics': true,
          'priority_support': false,
        };
      case SubscriptionType.enterprise:
        return {
          'max_projects': double.infinity,
          'max_team_members': double.infinity,
          'advanced_analytics': true,
          'priority_support': true,
        };
    }
  }
}