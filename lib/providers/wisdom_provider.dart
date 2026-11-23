import 'package:flutter/foundation.dart';

import '../repositories/wisdom_repository.dart';

class WisdomProvider extends ChangeNotifier {
  WisdomProvider({required this.repository});
  final WisdomRepository repository;
  WisdomQuote _quote =
      const WisdomQuote(text: 'Sabedoria do dia', author: 'NightOwlner');
  bool _loading = false;
  DateTime? _loadedDate;
  WisdomQuote get quote => _quote;
  bool get isLoading => _loading;

  Future<void> load() async {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    if (_loading || _loadedDate == todayKey) return;
    _loading = true;
    notifyListeners();
    _quote = await repository.loadQuote();
    _loadedDate = todayKey;
    _loading = false;
    notifyListeners();
  }
}
