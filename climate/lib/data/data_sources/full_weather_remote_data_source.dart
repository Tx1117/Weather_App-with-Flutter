import 'dart:convert';
import 'package:climate/core/either.dart';
import 'package:climate/core/failure.dart';
import 'package:climate/domain/entities/full_weather.dart';
import 'package:riverpod/riverpod.dart';
import 'package:climate/core/functions.dart';
import 'package:climate/data/models/full_weather_model.dart';
import 'package:climate/data/repos/api_key_repo.dart';
import 'package:climate/data/repos/geocoding_repo.dart';
import 'package:http/http.dart' as http;
import 'package:climate/domain/entities/city.dart';

class FullWeatherRemoteDataSource {
  FullWeatherRemoteDataSource(this._apiKeyRepo, this._geocodingRepo);
  final ApiKeyRepo _apiKeyRepo;
  final GeocodingRepo _geocodingRepo;

  Future<Either<Failure, FullWeather>> getFullWeather(City city) async {
    final apiKeyModel = (await _apiKeyRepo.getApiKey()).fold((_) => null, id)!;

    final coordinates = (await _geocodingRepo.getCoordinates(
      city,
    )).fold((_) => null, id)!;

    final response = await http.get(
      Url(
        scheme: 'https',
        host: 'api.openweathermap.org',
        path: '/data/2.5/onecall',
        queryParameters: {
          'lon': coordinates.long.toString(),
          'lat': coordinates.lat.toString(),
          'appid': apiKeyModel.apiKey,
          'units': 'metric',
          'exclude': 'minutely,alerts',
        },
      ),
    );

    if (response.statusCode >= 200 && response.statusCode <= 226) {
      try {
        return Right(
          FullWeatherModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
            city: city,
          ),
        );
      } on FormatException {
        return const Left(FailedToParseResponse());
      }
    } else if (response.statusCode == 503) {
      return const Left(ServerDown());
    } else if (response.statusCode == 404) {
      return Left(InvalidCityName(city.name));
    } else if (response.statusCode == 429) {
      return const Left(CallLimitExceeded());
    } else {
      return const Left(FailedToParseResponse());
    }
  }
}

final FullWeatherRemoteDataSourceProvider = Provider(
  (ref) => FullWeatherRemoteDataSource(
    ref.watch(apiKeyRepoProvider),
    ref.watch(geocodingRepoProvider),
  ),
);
