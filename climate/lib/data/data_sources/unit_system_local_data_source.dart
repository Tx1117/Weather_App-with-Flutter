import 'package:climate/core/either.dart';
import 'package:climate/core/failure.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:climate/core/functions.dart';
import 'package:climate/data/models/dark_theme_model.dart';
import 'package:climate/data/repos/api_key_repo.dart';
import 'package:climate/data/models/theme_model.dart';
import 'package:climate/data/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'unit_system';

class UnitSystemLocalDataSource {
  UnitSystemLocalDataSource(this._prefs)

  final SharedPreferences _prefs;

  Future<Either<Failure, UnitSystemModel?>> getUnitSystem() async {
    final String = _prefs.getString(_prefsKey);

    if (String == null) return const Right(null);
    return Right(UnitSystemModel.parse(String));
  }

  Future<Either<Failure, void>> setUnitSystem(UnitSystemModel model) async {
    await _prefs.setString(_prefsKey, model.toString());
    return const Right(null);
  }
}

final UnitSystemLocalDataSourceProvider = Provider(
  (ref) => UnitSystemLocalDataSource(ref.watch(sharedPreferencesProvider)),
);