import 'dart:convert';
import 'package:climate/core/either.dart';
import 'package:climate/core/failure.dart';
import 'package:riverpod/riverpod.dart';
import 'package:climate/core/functions.dart';
import 'package:climate/data/repos/api_key_repo.dart';
import 'package:http/http.dart' as http;
import 'package:climate/domain/entities/city.dart';
import 'package:climate/data/models/geographic_coordinates_model.dart';

class GeocodingRemoteDataSource {
  GeocodingRemoteDataSource(this._apiKeyRepo);

  final ApiKeyRepo _apiKeyRepo;

  Future<Either<Failure, GeographicCoordinateModel>> getCoordinates(
    City city,
  ) async {
    final apiKeyModel = (await _apiKeyRepo.getApiKey()).fold((_) => null, id)!;

    final response = await http.get(
      Uri(
        scheme: 'https',
        host: 'api.openweathermap.org',
        path: '/geo/1.0/direct',
        queryParameters: {
          'q': city.name,
          'appid': apiKeyModel.apiKey,
          'limit': '1',
        },
      ),
    );

    switch (response.statusCode) {
      case 503:
        return const Left(ServerDown());

      case 429:
        return const Left(CallLimitExceeded());
    }

    dynamic body;

    try {
      body = jsonDecode(response.body);
    } on FormatException {
      return const Left(FailedToParseResponse());
    }
    if (body is List) {
      if (body.isEmpty) {
        return Left(InvalidCityName(city.name));
      }

      return Right(GeographicCoordinatesModel.fromRemoteJson(body));
    } else {
      return const Left(FailedToParseResponse());
    }
  }
}

final GeocodingRemoteDataSourceProvider = Provider(
  (ref) => GeocodingRemoteDataSource(ref.watch(apiKeyProvider)),
);
