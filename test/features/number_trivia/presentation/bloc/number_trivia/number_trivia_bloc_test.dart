import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_app/core/util/input_converter.dart';
import 'package:tdd_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_app/features/number_trivia/presentation/bloc/number_trivia/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<InputConverter>(as: #MockInputConverter),
  MockSpec<GetConcreteNumberTrivia>(as: #MockGetConcreteNumberTrivia),
  MockSpec<GetRandomNumberTrivia>(as: #MockGetRandomNumberTrivia),
])
void main() {
  NumberTriviaBloc? bloc;
  MockGetConcreteNumberTrivia? mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter? mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia!,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter!,
    );
  });

  test('initialState should be Empty', () {
    // assert
    expect(bloc?.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    final tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter?.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        // act
        bloc?.add(GetTriviaForConcreteNumberEvent(tNumberString));
        await untilCalled(mockInputConverter?.stringToUnsignedInteger(any));
        // assert
        verify(mockInputConverter?.stringToUnsignedInteger(tNumberString));
      },
    );

    test(
      'should emit [Error] when the input is invalid',
      () async {
        // arrange
        when(mockInputConverter?.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));

        // act
        bloc?.add(GetTriviaForConcreteNumberEvent(tNumberString));
        debugPrint(bloc?.state.toString());
        await Future.delayed(const Duration(milliseconds: 500), () {});
        expect(
            bloc?.state, const Error(message: INVALID_INPUT_FAILURE_MESSAGE));
      },
    );

    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia!(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // act
        bloc?.add(GetTriviaForConcreteNumberEvent(tNumberString));
        await untilCalled(mockGetConcreteNumberTrivia!(any));
        // assert
        verify(
          mockGetConcreteNumberTrivia!(
            ConcreteNumberTriviaParams(number: tNumberParsed),
          ),
        );
      },
    );

    test(
      'should emit [Loaded] when get concrete number trivia success',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        var numberTriviaSample = NumberTrivia(number: 2, text: 'berhasil');
        when(mockGetConcreteNumberTrivia!(any)).thenAnswer((_) async => Right(numberTriviaSample));

        // act
        bloc?.add(GetTriviaForConcreteNumberEvent(tNumberString));
        debugPrint(bloc?.state.toString());
        await Future.delayed(const Duration(milliseconds: 500), () {});
        expect(
            bloc?.state, Loaded(trivia: numberTriviaSample));
      },
    );
  });
}
