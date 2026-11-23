import 'dart:convert';

import 'package:http/http.dart' as http;

class WisdomQuote {
  const WisdomQuote({required this.text, required this.author});
  final String text;
  final String author;
}

class WisdomRepository {
  WisdomRepository({this.fetchZen, this.fetchAdvice, http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final Future<WisdomQuote> Function()? fetchZen;
  final Future<WisdomQuote> Function()? fetchAdvice;

  Future<WisdomQuote> loadQuote() async {
    try {
      return await (fetchZen?.call() ?? _fetchZen())
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      try {
        return await (fetchAdvice?.call() ?? _fetchAdvice())
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        return const WisdomQuote(
            text: 'Pequenos passos consistentes constroem grandes projetos.',
            author: 'Coruja NightOwlner');
      }
    }
  }

  Future<WisdomQuote> _fetchZen() async {
    final response =
        await _client.get(Uri.parse('https://zenquotes.io/api/random'));
    if (response.statusCode != 200) {
      throw StateError('ZenQuotes indisponível');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    final item = list.first as Map<String, dynamic>;
    return WisdomQuote(
        text: item['q'] as String,
        author: item['a'] as String? ?? 'Autor desconhecido');
  }

  Future<WisdomQuote> _fetchAdvice() async {
    final response =
        await _client.get(Uri.parse('https://api.adviceslip.com/advice'));
    if (response.statusCode != 200) {
      throw StateError('Advice Slip indisponível');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final slip = map['slip'] as Map<String, dynamic>;
    return WisdomQuote(text: slip['advice'] as String, author: 'Advice Slip');
  }
}
