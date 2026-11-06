import 'package:flutter/material.dart';


import 'app/app.dart';
import 'services/backend_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  BackendTest.testConnection();

  runApp(const PayEaseApp());
}
