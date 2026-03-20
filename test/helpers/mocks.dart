import 'package:mocktail/mocktail.dart';

import 'package:gloo/data/interfaces/i_remote_repository.dart';
import 'package:gloo/services/analytics_service.dart';
import 'package:gloo/services/ad_manager.dart';

class MockRemoteRepository extends Mock implements IRemoteRepository {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockAdManager extends Mock implements AdManager {}
