import 'package:flutter/material.dart';
import '../../patients/models/patient_model.dart';
import 'patient_map_card.dart';

class MapBottomSheet extends StatelessWidget {
  final List<PatientModel> patients;
  final Function(PatientModel) onPatientTap;

  const MapBottomSheet({Key? key, required this.patients, required this.onPatientTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -3))],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Daftar Persebaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFFE9F0FF), borderRadius: BorderRadius.circular(8)),
                            child: Text('${patients.length} Pasien', style: const TextStyle(color: Color(0xFF1060EF), fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              patients.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            '0 data pasien ditemukan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => PatientMapCard(
                            patient: patients[index],
                            onTap: () => onPatientTap(patients[index]),
                          ),
                          childCount: patients.length,
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}