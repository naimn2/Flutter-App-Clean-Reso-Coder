import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_app/core/util/input_converter.dart';

void main() {
  InputConverter? inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {

    test(
      'should return an integer when the string represents an unsigned integer',
      () async {
        // arrange
        final str = '123';
        // act
        final result = inputConverter?.stringToUnsignedInteger(str);
        // assert
        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      'should return an Failure when the string represents a not int',
      () async {
        // arrange
        final str = 'abc';
        // act
        final result = inputConverter?.stringToUnsignedInteger(str);
        // assert
        expect(result, Left(InvalidInputFailure()));
      },
    );

    test(
      'should return an Failure when the string represents a negative number',
      () async {
        // arrange
        final str = '-123';
        // act
        final result = inputConverter?.stringToUnsignedInteger(str);
        // assert
        expect(result, Left(InvalidInputFailure()));
      },
    );
  });
}