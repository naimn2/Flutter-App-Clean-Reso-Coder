import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdd_app/core/error/failures.dart';
import 'package:tdd_app/core/usecases/usecase.dart';

import '../../../../../core/util/input_converter.dart';
import '../../../domain/entities/number_trivia.dart';
import '../../../domain/usecases/get_concrete_number_trivia.dart';
import '../../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    _registerGetConcreteNumberTriviaEvent();
    _registerGetRandomNumberTriviaEvent();
  }

  NumberTriviaState get initialState => Empty();

  void _registerGetConcreteNumberTriviaEvent() =>
      on<GetTriviaForConcreteNumberEvent>((event, emit) async {
        final inputEither =
            inputConverter.stringToUnsignedInteger(event.numberString);

        Error? error;
        int? query;
        inputEither.fold(
          (failure) => error = const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
          (integer) => query = integer,
        );
        if (error != null) {
          emit(error!);
        } else {
          emit(Loading());
          final failureOrTrivia = await getConcreteNumberTrivia(
            ConcreteNumberTriviaParams(number: query!),
          );
          final fold = failureOrTrivia.fold(
            (failure) => Error(
              message: _mapFailureToMessage(failure),
            ),
            (numberTrivia) => Loaded(trivia: numberTrivia),
          );
          emit(fold);
        }
      });

  void _registerGetRandomNumberTriviaEvent() =>
      on<GetTriviaForRandomNumberEvent>((event, emit) async {
        emit(Loading());

        final failureOrTrivia = await getRandomNumberTrivia(NoParams());
        emit(failureOrTrivia.fold(
          (failure) => Error(message: _mapFailureToMessage(failure)),
          (numberTrivia) => Loaded(trivia: numberTrivia),
        ));
      });
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;
    case CacheFailure:
      return CACHE_FAILURE_MESSAGE;
    default:
      return 'Unexpected Error';
  }
}
