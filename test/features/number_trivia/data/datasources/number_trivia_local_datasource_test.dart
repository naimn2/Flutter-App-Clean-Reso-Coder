import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_app/core/error/exception.dart';
import 'package:tdd_app/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_app/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl? dataSource;
  MockSharedPreferences? mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences!,
    );
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
        // arrange
        when(mockSharedPreferences?.getString(any!))
            .thenReturn(fixture('trivia_cached.json'));
        // act
        final result = await dataSource?.getLastNumberTrivia();
        // assert
        verify(mockSharedPreferences?.getString('CACHED_NUMBER_TRIVIA'));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test('should throw a CacheException when there is not a cached value', () {
      // arrange
      when(mockSharedPreferences?.getString(any!)).thenReturn(null);
      // act
      // Not calling the method here, just storing it inside a call variable
      final call = dataSource?.getLastNumberTrivia;
      // assert
      // Calling the method happens from a higher-order function passed.
      // This is needed to test if calling a method throws an exception.
      expect(() => call!(), throwsA(TypeMatcher<CacheException>()));
    });
  });
}
