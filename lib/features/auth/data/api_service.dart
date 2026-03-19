import 'package:health_care_app/core/network/base_api.dart';
import 'package:health_care_app/features/auth/data/auth_api.dart';
import 'package:health_care_app/features/patient/data/patient_api.dart';
import 'package:health_care_app/features/health/data/health_api.dart';
import 'package:health_care_app/features/medicine/data/medicine_api.dart';
import 'package:health_care_app/features/meal/data/meal_api.dart';
import 'package:health_care_app/features/notification/data/notification_api.dart';

class ApiService extends BaseApi
    with
        AuthApi,
        PatientApi,
        HealthApi,
        MedicineApi,
        MealApi,
        NotificationApi {}
