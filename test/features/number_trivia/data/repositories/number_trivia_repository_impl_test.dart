import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_app/core/platform/network_info.dart';
import 'package:tdd_app/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_app/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_app/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_app/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl? repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo? mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo!,
    );
  });

  group('getConcreteNumberTrivia', () {
  // DATA FOR THE MOCKS AND ASSERTIONS
  // We'll use these three variables throughout all the tests
  final tNumber = 1;
  final tNumberTriviaModel =
      NumberTriviaModel(number: tNumber, text: 'test trivia');
  final NumberTrivia tNumberTrivia = tNumberTriviaModel;

  test('should check if the device is online', () {
    //arrange
    when(mockNetworkInfo?.isConnected).thenAnswer((_) async => true);
    // act
    repository?.getConcreteNumberTrivia(tNumber);
    // assert
    verify(mockNetworkInfo?.isConnected);
  });
});
}