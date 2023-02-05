import 'package:tdd_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:tdd_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/platform/network_info.dart';
import '../datasources/number_trivia_local_datasource.dart';
import '../datasources/number_trivia_remote_datasource.dart';
import '../models/number_trivia_model.dart';

typedef _ConcreteOrRandomChooser = Future<NumberTriviaModel> Function();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int? number) async {
    return _getNumberTrivia(() => remoteDataSource.getConcreteNumberTrivia(number!));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return _getNumberTrivia(remoteDataSource.getRandomNumberTrivia);
  }

  Future<Either<Failure, NumberTrivia>> _getNumberTrivia(
      _ConcreteOrRandomChooser getConcreteOrRandom) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteOrRandom();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
