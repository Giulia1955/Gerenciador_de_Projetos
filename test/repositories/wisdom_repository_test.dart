import 'package:apk_auth/repositories/wisdom_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns local fallback when external clients fail', () async {
    final repository = WisdomRepository(
      fetchZen: () async => throw StateError('offline'),
      fetchAdvice: () async => throw StateError('offline'),
    );

    final quote = await repository.loadQuote();

    expect(quote.text, isNotEmpty);
    expect(quote.author, isNotEmpty);
  });
}
