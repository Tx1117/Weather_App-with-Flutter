import 'dart:math';
import 'package:climate/core/either.dart';
import 'package:climate/core/failure.dart';
import 'package:climate/data/models/api_key_model.dart';
import 'package:riverpod/riverpod.dart';
import 'package:climate/domain/entities/city.dart';

const _randomCityNames = [
  'New York',
  'Los Angeles',
  'Chicago',
  'Houston',
  'Philadelphia',
  'Sydney',
  'Kathmandu',
  'Delhi',
  'Texas',
  'Tokyo',
];

class CityRandomDataSource {
  Future<Either<Failure, CityModel>> getCity() async => Right(
    CityModel(
      city(name: _randomCityNames[Random().nextInt(_randomCityNames.length)]),
    ),
  );
}

final cityRandomDataSourceProvider = Provider((ref) => CityRandomDataSource());
