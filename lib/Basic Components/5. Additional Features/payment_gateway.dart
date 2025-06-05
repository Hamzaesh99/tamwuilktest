import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PaymentMethod {
  creditCard,
  bankTransfer,
  paypal,
  applePay,
  googlePay,
  mada,
  stcPay,
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled,
}

class PaymentGateway {
  final supabase = Supabase.instance.client;

  // ÅäÔÇÁ ãÚÇãáÉ ÏÝÚ ÌÏíÏÉ
  Future<Map<String, dynamic>> createPayment({
    required String userId,
    required String projectId,
    required double amount,
    required PaymentMethod method,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // ÅäÔÇÁ ãÚÑÝ ÝÑíÏ ááãÚÇãáÉ
      final String transactionId =
          DateTime.now().millisecondsSinceEpoch.toString();

      // ÊÓÌíá ÇáãÚÇãáÉ Ýí ÞÇÚÏÉ ÇáÈíÇäÇÊ
      final response =
          await supabase
              .from('payments')
              .insert({
                'transaction_id': transactionId,
                'user_id': userId,
                'project_id': projectId,
                'amount': amount,
                'payment_method': method.toString(),
                'status': PaymentStatus.pending.toString(),
                'description': description,
                'metadata': metadata,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      return response;
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÅäÔÇÁ ãÚÇãáÉ ÇáÏÝÚ: $e');
      return {'error': e.toString()};
    }
  }

  // ãÚÇáÌÉ ÇáÏÝÚ ÈÇÓÊÎÏÇã ÈæÇÈÉ ÏÝÚ ÎÇÑÌíÉ
  Future<Map<String, dynamic>> processPayment({
    required String transactionId,
    required PaymentMethod method,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      // ÊÍÏíË ÍÇáÉ ÇáãÚÇãáÉ Åáì "ÞíÏ ÇáãÚÇáÌÉ"
      await supabase
          .from('payments')
          .update({'status': PaymentStatus.processing.toString()})
          .eq('transaction_id', transactionId);

      // ãÚÇáÌÉ ÇáÏÝÚ ÍÓÈ ÇáØÑíÞÉ ÇáãÎÊÇÑÉ
      Map<String, dynamic> result;

      switch (method) {
        case PaymentMethod.creditCard:
          result = await _processCreditCardPayment(
            transactionId,
            paymentDetails,
          );
          break;
        case PaymentMethod.bankTransfer:
          result = await _processBankTransferPayment(
            transactionId,
            paymentDetails,
          );
          break;
        case PaymentMethod.paypal:
          result = await _processPaypalPayment(transactionId, paymentDetails);
          break;
        case PaymentMethod.applePay:
          result = await _processApplePayPayment(transactionId, paymentDetails);
          break;
        case PaymentMethod.googlePay:
          result = await _processGooglePayPayment(
            transactionId,
            paymentDetails,
          );
          break;
        case PaymentMethod.mada:
          result = await _processMadaPayment(transactionId, paymentDetails);
          break;
        case PaymentMethod.stcPay:
          result = await _processStcPayPayment(transactionId, paymentDetails);
          break;
      }

      // ÊÍÏíË ÍÇáÉ ÇáãÚÇãáÉ ÈäÇÁð Úáì äÊíÌÉ ÇáãÚÇáÌÉ
      final newStatus =
          result['success'] ? PaymentStatus.completed : PaymentStatus.failed;

      await supabase
          .from('payments')
          .update({
            'status': newStatus.toString(),
            'payment_response': result,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('transaction_id', transactionId);

      return result;
    } catch (e) {
      debugPrint('ÎØÃ Ýí ãÚÇáÌÉ ÇáÏÝÚ: $e');

      // ÊÍÏíË ÍÇáÉ ÇáãÚÇãáÉ Åáì "ÝÔá"
      await supabase
          .from('payments')
          .update({
            'status': PaymentStatus.failed.toString(),
            'error_message': e.toString(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('transaction_id', transactionId);

      return {'success': false, 'error': e.toString()};
    }
  }

  // ÇÓÊÑÏÇÏ ÇáÃãæÇá
  Future<Map<String, dynamic>> refundPayment({
    required String transactionId,
    double? amount,
    String? reason,
  }) async {
    try {
      // ÇáÊÍÞÞ ãä æÌæÏ ÇáãÚÇãáÉ æÍÇáÊåÇ
      final payment =
          await supabase
              .from('payments')
              .select()
              .eq('transaction_id', transactionId)
              .single();

      if (payment['status'] != PaymentStatus.completed.toString()) {
        return {
          'success': false,
          'message': 'áÇ íãßä ÇÓÊÑÏÇÏ ãÚÇãáÉ ÛíÑ ãßÊãáÉ',
        };
      }

      // ÅÌÑÇÁ ØáÈ ÇáÇÓÊÑÏÇÏ Åáì ÈæÇÈÉ ÇáÏÝÚ
      // åäÇ íãßä ÅÖÇÝÉ ÇáÇÊÕÇá ÈÈæÇÈÉ ÇáÏÝÚ ÇáÝÚáíÉ

      // ÊÍÏíË ÍÇáÉ ÇáãÚÇãáÉ
      await supabase
          .from('payments')
          .update({
            'status': PaymentStatus.refunded.toString(),
            'refund_amount': amount ?? payment['amount'],
            'refund_reason': reason,
            'refunded_at': DateTime.now().toIso8601String(),
          })
          .eq('transaction_id', transactionId);

      return {'success': true, 'message': 'Êã ÇÓÊÑÏÇÏ ÇáãÈáÛ ÈäÌÇÍ'};
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÇÓÊÑÏÇÏ ÇáãÈáÛ: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ÇáÍÕæá Úáì ÊÝÇÕíá ãÚÇãáÉ
  Future<Map<String, dynamic>> getPaymentDetails(String transactionId) async {
    try {
      final payment =
          await supabase
              .from('payments')
              .select('*, users:user_id(*), projects:project_id(*)')
              .eq('transaction_id', transactionId)
              .single();

      return payment;
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÌáÈ ÊÝÇÕíá ÇáãÚÇãáÉ: $e');
      return {};
    }
  }

  // ÇáÍÕæá Úáì ÞÇÆãÉ ãÚÇãáÇÊ ÇáãÓÊÎÏã
  Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    try {
      final payments = await supabase
          .from('payments')
          .select('*, projects:project_id(name, image_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(payments);
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÌáÈ ãÚÇãáÇÊ ÇáãÓÊÎÏã: $e');
      return [];
    }
  }

  // ÇáÍÕæá Úáì ÞÇÆãÉ ãÚÇãáÇÊ ÇáãÔÑæÚ
  Future<List<Map<String, dynamic>>> getProjectPayments(
    String projectId,
  ) async {
    try {
      final payments = await supabase
          .from('payments')
          .select('*, users:user_id(name, avatar_url)')
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(payments);
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÌáÈ ãÚÇãáÇÊ ÇáãÔÑæÚ: $e');
      return [];
    }
  }

  // ãÚÇáÌÉ ÇáÏÝÚ ÈÈØÇÞÉ ÇáÇÆÊãÇä
  Future<Map<String, dynamic>> _processCreditCardPayment(
    String transactionId,
    Map<String, dynamic> paymentDetails,
  ) async {
    // åäÇ íãßä ÅÖÇÝÉ ÇáÇÊÕÇá ÈÈæÇÈÉ ÏÝÚ ÍÞíÞíÉ ãËá Stripe Ãæ PayFort
    // åÐÇ ãÌÑÏ ãÍÇßÇÉ ááÚãáíÉ

    await Future.delayed(const Duration(seconds: 2)); // ãÍÇßÇÉ æÞÊ ÇáãÚÇáÌÉ

    // ÇáÊÍÞÞ ãä ÕÍÉ ÈíÇäÇÊ ÇáÈØÇÞÉ
    final cardNumber = paymentDetails['card_number'] as String?;
    final expiryDate = paymentDetails['expiry_date'] as String?;
    final cvv = paymentDetails['cvv'] as String?;

    if (cardNumber == null || expiryDate == null || cvv == null) {
      return {'success': false, 'message': 'ÈíÇäÇÊ ÇáÈØÇÞÉ ÛíÑ ãßÊãáÉ'};
    }

    // ãÍÇßÇÉ äÌÇÍ ÇáÚãáíÉ (Ýí ÇáæÇÞÚ íÌÈ ÇáÊÍÞÞ ãä ÕÍÉ ÇáÈØÇÞÉ)
    return {
      'success': true,
      'message': 'ÊãÊ ãÚÇáÌÉ ÇáÏÝÚ ÈäÌÇÍ',
      'transaction_id': transactionId,
      'payment_method': 'credit_card',
      'processed_at': DateTime.now().toIso8601String(),
    };
  }

  // ãÚÇáÌÉ ÇáÏÝÚ ÈÇáÊÍæíá ÇáÈäßí
  Future<Map<String, dynamic>> _processBankTransferPayment(
    String transactionId,
    Map<String, dynamic> paymentDetails,
  ) async {
    // ãÍÇßÇÉ ÚãáíÉ ÇáÊÍæíá ÇáÈäßí
    await Future.delayed(const Duration(seconds: 1));

    return {
      'success': true,
      'message': 'Êã ÅäÔÇÁ ØáÈ ÇáÊÍæíá ÇáÈäßí ÈäÌÇÍ',
      'transaction_id': transactionId,
      'bank_details': {
        'account_name': 'Êãæíáß ááÎÏãÇÊ ÇáãÇáíÉ',
        'account_number': '1234567890',
        'bank_name': 'ÇáÈäß ÇáÃåáí ÇáÓÚæÏí',
        'reference': transactionId,
      },
      'instructions':
          'íÑÌì ÊÍæíá ÇáãÈáÛ ÎáÇá 48 ÓÇÚÉ æÅÖÇÝÉ ÑÞã ÇáãÑÌÚ Ýí ÊÝÇÕíá ÇáÊÍæíá',
    };
  }

  // ãÚÇáÌÉ ÇáÏÝÚ ÚÈÑ PayPal
  Future<Map<String, dynamic>> _processPaypalPayment(
    String transactionId,
    Map<String, dynamic> paymentDetails,
  ) async {
    // ãÍÇßÇÉ ÇáÇÊÕÇá ÈÜ PayPal API
    await Future.delayed(const Duration(seconds: 2));

    return {
      'success': true,
      'message': 'Êã ÇáÏÝÚ ÚÈÑ PayPal ÈäÌÇÍ',
      'transaction_id': transactionId,
      'paypal_transaction_id': 'PP-${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // ãÚÇáÌÉ ÇáÏÝÚ ÚÈÑ Apple Pay
  Future<Map<String, dynamic>> _processApplePayPayment(
    String transactionId,
    Map<String, dynamic> paymentDetails,
  ) async {
    // ãÍÇßÇÉ ÇáÇÊÕÇá ÈÜ Apple Pay API
    await Future.delayed(const Duration(seconds: 1));

    return {
      'success': true,
      'message': 'Êã ÇáÏÝÚ ÚÈÑ Apple Pay ÈäÌÇÍ',
      'transaction_id': transactionId,
      'apple_transaction_id': 'AP-${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // ãÚÇáÌÉ ÇáÏÝÚ ÚÈÑ Google Pay
  Future<Map<String, dynamic>> _processGooglePayPayment(
    String transactionId,
    Map<String, dynamic> paymentDetails,
  ) async {
    // ãÍÇßÇÉ ÇáÇÊÕÇá ÈÜ Google Pay API
    await Future.delayed(const Duration(seconds: 1));

    return {
      'success': true,
      'message': 'Êã ÇáÏÝÚ ÚÈÑ Google Pay ÈäÌÇÍ',
      'transaction_id': transactionId,
      'google_transaction_id': 'GP-${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // ãÚÇáÌÉ ÇáÏÝÚ ÚÈÑ ãÏì
  Future<Map<String, dynamic>> _processMadaPayment(
    String transactionId,
    Map<String, dynamic> paymentDetails,
  ) async {
    // ãÍÇßÇÉ ÇáÇÊÕÇá ÈÜ ãÏì API
    await Future.delayed(const Duration(seconds: 1));

    return {
      'success': true,
      'message': 'Êã ÇáÏÝÚ ÚÈÑ ÈØÇÞÉ ãÏì ÈäÌÇÍ',
      'transaction_id': transactionId,
      'mada_transaction_id': 'MD-${DateTime.now().millisecondsSinceEpoch}',
    };
  }

  // ãÚÇáÌÉ ÇáÏÝÚ ÚÈÑ STC Pay
  Future<Map<String, dynamic>> _processStcPayPayment(
    String transactionId,
    Map<String, dynamic> paymentDetails,
  ) async {
    // ãÍÇßÇÉ ÇáÇÊÕÇá ÈÜ STC Pay API
    await Future.delayed(const Duration(seconds: 1));

    final phoneNumber = paymentDetails['phone_number'] as String?;

    if (phoneNumber == null) {
      return {
        'success': false,
        'message': 'ÑÞã ÇáåÇÊÝ ãØáæÈ ááÏÝÚ ÚÈÑ STC Pay',
      };
    }

    return {
      'success': true,
      'message': 'Êã ÅÑÓÇá ØáÈ ÇáÏÝÚ Åáì STC Pay ÈäÌÇÍ',
      'transaction_id': transactionId,
      'stc_pay_transaction_id': 'STC-${DateTime.now().millisecondsSinceEpoch}',
      'instructions': 'íÑÌì ÊÃßíÏ ÇáÏÝÚ ãä ÊØÈíÞ STC Pay Úáì åÇÊÝß',
    };
  }

  // ÇáÊÍÞÞ ãä ÍÇáÉ ÇáÏÝÚ
  Future<PaymentStatus> checkPaymentStatus(String transactionId) async {
    try {
      final payment =
          await supabase
              .from('payments')
              .select('status')
              .eq('transaction_id', transactionId)
              .single();

      return PaymentStatus.values.firstWhere(
        (status) => status.toString() == payment['status'],
        orElse: () => PaymentStatus.pending,
      );
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÇáÊÍÞÞ ãä ÍÇáÉ ÇáÏÝÚ: $e');
      return PaymentStatus.failed;
    }
  }

  // ÅäÔÇÁ ÝÇÊæÑÉ ááÏÝÚ
  Future<Map<String, dynamic>> generateInvoice(String transactionId) async {
    try {
      final payment = await getPaymentDetails(transactionId);

      if (payment.isEmpty) {
        return {
          'success': false,
          'message': 'áã íÊã ÇáÚËæÑ Úáì ãÚÇãáÉ ÈåÐÇ ÇáãÚÑÝ',
        };
      }

      // ÅäÔÇÁ ÈíÇäÇÊ ÇáÝÇÊæÑÉ
      final invoiceData = {
        'invoice_id': 'INV-$transactionId',
        'transaction_id': transactionId,
        'date': DateTime.now().toIso8601String(),
        'customer_name': payment['users']['name'],
        'customer_email': payment['users']['email'],
        'project_name': payment['projects']['name'],
        'amount': payment['amount'],
        'payment_method': payment['payment_method'],
        'status': payment['status'],
        'created_at': DateTime.now().toIso8601String(),
      };

      // ÍÝÙ ÇáÝÇÊæÑÉ Ýí ÞÇÚÏÉ ÇáÈíÇäÇÊ
      await supabase.from('invoices').insert(invoiceData);

      return {
        'success': true,
        'message': 'Êã ÅäÔÇÁ ÇáÝÇÊæÑÉ ÈäÌÇÍ',
        'invoice_data': invoiceData,
      };
    } catch (e) {
      debugPrint('ÎØÃ Ýí ÅäÔÇÁ ÇáÝÇÊæÑÉ: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
