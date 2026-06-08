import 'package:equatable/equatable.dart';

enum ConsultationType { first, followUp }
enum ConsultationStatus { draft, complete }

class ConsultationEntity extends Equatable {
  final String id;
  final String patientId;
  final String nutriologistId;
  final ConsultationType type;
  final ConsultationStatus status;
  final int currentStep;
  final String? appointmentId;
  final ConsultationStep1? step1;
  final ConsultationStep2? step2;
  final ConsultationStep3? step3;
  final ConsultationStep4? step4;
  final ConsultationStep5? step5;
  final ConsultationStep6? step6;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConsultationEntity({
    required this.id,
    required this.patientId,
    required this.nutriologistId,
    required this.type,
    required this.status,
    required this.currentStep,
    this.appointmentId,
    this.step1,
    this.step2,
    this.step3,
    this.step4,
    this.step5,
    this.step6,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDraft => status == ConsultationStatus.draft;
  bool get isComplete => status == ConsultationStatus.complete;
  double get progressPercent => currentStep / 6.0;

  @override
  List<Object?> get props => [id, patientId, status, currentStep];
}

// ── Paso 1: Metadatos ─────────────────────────────────────────────────────────
class ConsultationStep1 {
  final DateTime consultationDate;
  final String consultationTime;
  final String expediente;
  final String fullName;
  final int age;
  final String consultType;
  final bool isPregnant;
  final bool isMinor;
  final String? referralReason;
  final String? occupation;
  final String? educationLevel;
  final String? supportNetwork;

  const ConsultationStep1({
    required this.consultationDate,
    required this.consultationTime,
    required this.expediente,
    required this.fullName,
    required this.age,
    required this.consultType,
    required this.isPregnant,
    required this.isMinor,
    this.referralReason,
    this.occupation,
    this.educationLevel,
    this.supportNetwork,
  });
}

// ── Paso 2: Antropometría ─────────────────────────────────────────────────────
class ConsultationStep2 {
  final double height;
  final double currentWeight;
  final double? usualWeight;
  final double? pregestationalWeight;
  final int? gestationalWeeks;
  final double? waist;
  final double? hip;
  final double? armCircumference;
  final double? tricepsFold;

  const ConsultationStep2({
    required this.height,
    required this.currentWeight,
    this.usualWeight,
    this.pregestationalWeight,
    this.gestationalWeeks,
    this.waist,
    this.hip,
    this.armCircumference,
    this.tricepsFold,
  });

  double get imc => currentWeight / ((height / 100) * (height / 100));
  double get imcPregestacional => pregestationalWeight != null
      ? pregestationalWeight! / ((height / 100) * (height / 100))
      : imc;

  String get imcCategory {
    final v = imc;
    if (v < 18.5) return 'Bajo peso';
    if (v < 25) return 'Normopeso';
    if (v < 30) return 'Sobrepeso';
    return 'Obesidad';
  }
}

// ── Paso 3: Bioquímicos ───────────────────────────────────────────────────────
class ConsultationStep3 {
  final double? glucose;
  final double? hba1c;
  final double? totalCholesterol;
  final double? hdl;
  final double? ldl;
  final double? triglycerides;
  final double? hemoglobin;
  final double? ferritin;
  final double? creatinine;
  final String? observations;

  const ConsultationStep3({
    this.glucose,
    this.hba1c,
    this.totalCholesterol,
    this.hdl,
    this.ldl,
    this.triglycerides,
    this.hemoglobin,
    this.ferritin,
    this.creatinine,
    this.observations,
  });
}

// ── Paso 4: Dietética ─────────────────────────────────────────────────────────
class ConsultationStep4 {
  final Map<String, int> foodFrequency;
  final double waterLiters;
  final double? coffeeTea;
  final double? softDrinks;
  final String? whoPreparesFood;
  final int mealsPerDay;
  final int mealPrepTime;
  final String appetiteLevel;
  final List<String> preferredFoods;
  final List<String> allergiesIntolerances;
  final List<String> hungerHours;

  const ConsultationStep4({
    required this.foodFrequency,
    required this.waterLiters,
    this.coffeeTea,
    this.softDrinks,
    this.whoPreparesFood,
    required this.mealsPerDay,
    required this.mealPrepTime,
    required this.appetiteLevel,
    required this.preferredFoods,
    required this.allergiesIntolerances,
    required this.hungerHours,
  });
}

// ── Paso 5: Recordatorio 24h ──────────────────────────────────────────────────
class Meal24h {
  final String name;
  final String description;
  final String time;
  final String place;

  const Meal24h({
    required this.name,
    required this.description,
    required this.time,
    required this.place,
  });
}

class ConsultationStep5 {
  final Meal24h breakfast;
  final Meal24h? morningSnack;
  final Meal24h lunch;
  final Meal24h? afternoonSnack;
  final Meal24h dinner;

  const ConsultationStep5({
    required this.breakfast,
    this.morningSnack,
    required this.lunch,
    this.afternoonSnack,
    required this.dinner,
  });
}

// ── Paso 6: Diagnóstico PES ───────────────────────────────────────────────────
class MacroModification {
  final String nutrient;
  final String modification;
  final String? percentage;
  final String? action;

  const MacroModification({
    required this.nutrient,
    required this.modification,
    this.percentage,
    this.action,
  });
}

class ConsultationStep6 {
  final String findingsA;
  final String findingsB;
  final String findingsC;
  final String findingsD;
  final List<String> detectedProblems;
  final String pesNutritionProblem;
  final String pesEtiology;
  final String pesSigns;
  final String treatmentObjectives;
  final List<String> generalRecommendations;
  final List<MacroModification> macroModifications;

  const ConsultationStep6({
    required this.findingsA,
    required this.findingsB,
    required this.findingsC,
    required this.findingsD,
    required this.detectedProblems,
    required this.pesNutritionProblem,
    required this.pesEtiology,
    required this.pesSigns,
    required this.treatmentObjectives,
    required this.generalRecommendations,
    required this.macroModifications,
  });
}
