import 'package:domain/core/data_state.dart';
import 'package:domain/domain/payment/entity/payment.entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presentation/payment/provider/payment.provider.dart';

class PaymentPage extends ConsumerWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsFuture = ref.read(paymentUsecaseProvider).getPayments();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: FutureBuilder<DataState<List<PaymentEntity>>>(
        future: paymentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data ?? const DataState.initial();

          return state.when(
            initial: () => const Center(child: Text('결제 내역을 불러오는 중입니다.')),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            success: (payments) {
              if (payments.isEmpty) {
                return const Center(child: Text('결제 내역이 없습니다.'));
              }

              return ListView.separated(
                itemCount: payments.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return ListTile(
                    title: Text('${payment.amount}원'),
                    subtitle: Text(payment.status),
                    trailing: Text(payment.id),
                  );
                },
              );
            },
            error: (error, message, data) {
              return Center(child: Text(message ?? '오류가 발생했습니다.'));
            },
          );
        },
      ),
    );
  }
}
