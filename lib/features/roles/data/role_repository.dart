import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/role_model.dart';

class RoleRepository {
  Future<RolePack> loadTravelerPack() async {
    final String response = await rootBundle.loadString(RoleContent.packPath);
    final data = await json.decode(response);
    return RolePack.fromJson(data);
  }
}

final roleRepository = RoleRepository();
