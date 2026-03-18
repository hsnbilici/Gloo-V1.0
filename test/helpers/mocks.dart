import 'package:mocktail/mocktail.dart';

import 'package:gloo/data/remote/remote_repository.dart';
import 'package:gloo/services/analytics_service.dart';
import 'package:gloo/services/ad_manager.dart';

class MockRemoteRepository extends Mock implements RemoteRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockAdManager extends Mock implements AdManager {}
