import 'package:flutter/foundation.dart';

import '../repo/referral_repo.dart';

class ReferralController extends ChangeNotifier {
  final ReferralRepository referralRepository;
  ReferralController({required this.referralRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Initialize as an empty list to avoid null errors in the UI
  List<dynamic> _referralData = [];
  List<dynamic> get referralData => _referralData;

  Future<void> fetchReferralLevels() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await referralRepository.getReferralLevelwise();

      // According to your screenshot, the actual list is inside the 'data' key
      if (response != null && response['data'] != null) {
        _referralData = response['data'];
      } else {
        _referralData = [];
      }
    } catch (e) {
      debugPrint("Error fetching referrals: $e");
      _referralData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
