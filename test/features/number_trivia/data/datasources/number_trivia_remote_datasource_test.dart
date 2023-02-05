import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_app/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_datasource_test.mocks.dart';

@GenerateMocks([],customMocks: [MockSpec<Client>(as: #MockHttpClient)])
void main() {
  NumberTriviaRemoteDataSourceImpl? dataSource;
  MockHttpClient? mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient!);
  });

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;

    test(
      'should preform a GET request on a URL with number being the endpoint and with application/json header',
      () {
        //arrange
        when(mockHttpClient?.get(any, headers: anyNamed('headers')))
            .thenAnswer(
          (_) async => Response(fixture('trivia.json'), 200),
        );
        // act
        dataSource?.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockHttpClient?.get(
          Uri.parse('http://numbersapi.com/$tNumber'),
          headers: {'Content-Type': 'application/json'},
        ));
      },
    );
  });
}
