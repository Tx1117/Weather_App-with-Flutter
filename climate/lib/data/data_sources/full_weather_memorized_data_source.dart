import 'dart:math';
import 'package:climate/core/either.dart';
import 'package:climate/core/failure.dart';

import 'package:riverpod/riverpod.dart';
import 'package:climate/domain/entities/full_weather.dart';

class FullWeatherMemorizedDataSource {
  FullWeather? _fullWeather;

  DateTime? _fetchingTime;

  static const _invalidationDuration = Duration(minutes: 10);

  Future<Either<Failure, FullWeather>> getFullWeather() async {
    if (_fullWeather == null) return const Right(null);

    if (DateTime.now().difference(_fetchingTime!) >= _invalidationDuration) {
      _fullWeather = null;
      _fetchingTime = null;
      return const Right(null);
    }

    await Future<void>.delayed(
      Duration(milliseconds: 200 + Random().nextInt(800 - 200)),
    );

    return Right(_fullWeather);
  }

  Future<Either<Failure, void>> setFullWeather(FullWeather fullWeather) async {
    _fullWeather = fullWeather;
    _fetchingTime = DateTime.now();
    return const Right(null);
  }
}

final fullWeatherMemorizedDataSourceProvider = Provider(
  (ref) => FullWeatherMemorizedDataSource(),
);
