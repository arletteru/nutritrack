// features/home/presentation/providers/home_providers.dart
//
// Home no tiene domain propio: agrega streams de otros features
// para construir el dashboard de cada rol.
// Todos los imports vienen de los providers de sus respectivos features.

export '../../../auth/presentation/providers/auth_providers.dart';
export '../../../patients/presentation/providers/patients_providers.dart';
export '../../../schedule/presentation/providers/schedule_providers.dart';
export '../../../daily_log/presentation/providers/daily_log_providers.dart';
export '../../../recommendations/presentation/providers/recommendations_providers.dart';
