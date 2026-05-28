import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/faskes_model.dart';
import '../../data/models/faskes_detail_model.dart';
import '../../data/models/faskes_upsert_request.dart';
import '../../data/repositories/faskes_management_repository.dart';

final faskesManagementProvider = FutureProvider.autoDispose<List<FaskesModel>>((
  ref,
) async {
  final repository = ref.watch(faskesManagementRepositoryProvider);

  return await repository.getAllFaskes();
});

final faskesDetailProvider = FutureProvider.autoDispose
    .family<FaskesDetailModel, String>((ref, faskesId) async {
      final repository = ref.watch(faskesManagementRepositoryProvider);
      return await repository.getFaskesById(faskesId);
    });

final faskesMutationControllerProvider = Provider<FaskesMutationController>(
  (ref) => FaskesMutationController(ref),
);

final faskesFormControllerProvider =
    NotifierProvider.autoDispose<FaskesFormController, FaskesFormState>(
      FaskesFormController.new,
    );

class FaskesFormState {
  final String selectedKategori;
  final LatLng? selectedCoordinate;

  const FaskesFormState({
    this.selectedKategori = 'Puskesmas',
    this.selectedCoordinate,
  });

  FaskesFormState copyWith({
    String? selectedKategori,
    LatLng? selectedCoordinate,
    bool clearSelectedCoordinate = false,
  }) {
    return FaskesFormState(
      selectedKategori: selectedKategori ?? this.selectedKategori,
      selectedCoordinate: clearSelectedCoordinate
          ? null
          : selectedCoordinate ?? this.selectedCoordinate,
    );
  }
}

class FaskesFormController extends Notifier<FaskesFormState> {
  @override
  FaskesFormState build() {
    return const FaskesFormState();
  }

  void initialize({String? selectedKategori, LatLng? selectedCoordinate}) {
    state = FaskesFormState(
      selectedKategori: selectedKategori ?? state.selectedKategori,
      selectedCoordinate: selectedCoordinate,
    );
  }

  void setKategori(String kategori) {
    state = state.copyWith(selectedKategori: kategori);
  }

  void setCoordinate(LatLng coordinate) {
    state = state.copyWith(selectedCoordinate: coordinate);
  }

  void clearCoordinate() {
    state = state.copyWith(clearSelectedCoordinate: true);
  }
}

class FaskesMutationController {
  FaskesMutationController(this._ref);

  final Ref _ref;

  Future<FaskesMutationResult> createFaskes(FaskesUpsertRequest request) {
    final repository = _ref.read(faskesManagementRepositoryProvider);
    return repository.createFaskes(request);
  }

  Future<FaskesMutationResult> updateFaskes(
    String faskesId,
    FaskesUpsertRequest request,
  ) {
    final repository = _ref.read(faskesManagementRepositoryProvider);
    return repository.updateFaskes(faskesId, request);
  }
}
