import 'package:flutter/foundation.dart';

import '../repositories/wisdom_repository.dart';

class WisdomProvider extends ChangeNotifier {
  WisdomProvider({required this.repository});
  final WisdomRepository repository;
  WisdomQuote _quote =
      const WisdomQuote(text: 'Sabedoria do dia', author: 'NightOwlner');
  bool _loading = false;
  WisdomQuote get quote => _quote;
  bool get isLoading => _loading;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    _quote = await repository.loadQuote();
    _loading = false;
    notifyListeners();
  }
}
