import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:tdd_app/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../entities/number_trivia.dart';
import '../repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia extends UseCase<NumberTrivia, ConcreteNumberTriviaParams>{
  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(ConcreteNumberTriviaParams params) async {
    return repository.getConcreteNumberTrivia(params.number);
  }
}

class ConcreteNumberTriviaParams extends Equatable {
  final int number;

  ConcreteNumberTriviaParams({required this.number});
  
  @override
  List<Object?> get props => [number];
}