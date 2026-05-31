import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/medicine_provider.dart';

class TestMedicinePage extends ConsumerWidget {
  const TestMedicinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(
      medicineProvider("11111111-1111-1111-1111-111111111111"),
    );

    return Scaffold(
      body: medicines.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, index) {
              return ListTile(title: Text(data[index].name));
            },
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
