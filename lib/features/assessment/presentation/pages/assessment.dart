import 'package:flutter/material.dart';
import 'package:nutritrack/features/assessment/presentation/widgets/chips_card.dart';
import 'package:nutritrack/features/assessment/presentation/widgets/closed_ended_question.dart';
import 'package:nutritrack/features/assessment/presentation/widgets/custom_expansion_tile.dart';
import 'package:nutritrack/features/assessment/presentation/widgets/custom_text_field.dart';
import 'package:nutritrack/features/assessment/presentation/widgets/section_card.dart';
import 'package:nutritrack/features/assessment/presentation/widgets/switch_card.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        alignment: .topRight,
        padding: .all(20),
        child: Column(
          spacing: 20,
          mainAxisAlignment: .start,
          children: [
            SectionCard(
              sectionName: 'Metadatos',
              sectionIcon: Icons.calendar_month,
              childWidget: Column(
                spacing: 15,
                crossAxisAlignment: .start,
                children: [
                  CustomTextField(
                    label: 'Fecha de consulta',
                    hintText: '10/04/2026',
                    sufIcon: Icons.calendar_today,
                  ),
                  CustomTextField(
                    label: 'Hora',
                    hintText: '02:30 PM',
                    sufIcon: Icons.timer_sharp,
                  ),
                ],
              ),
            ),
            SectionCard(
              sectionName: 'Identificación del paciente',
              sectionIcon: Icons.contact_mail_rounded,
              childWidget: Column(
                spacing: 15,
                children: [
                  CustomTextField(label: 'Expediente'),
                  CustomTextField(label: 'Nombre Completo'),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(child: CustomTextField(label: 'Edad Exacta')),
                      Text('años'),
                    ],
                  ),
                ],
              ),
            ),
            SectionCard(
              background: Theme.of(context).cardColor,
              sectionName: 'Clasificación',
              sectionIcon: Icons.category,
              childWidget: Column(
                spacing: 15,
                children: [
                  CustomTextField(
                    filledColor: Colors.white,
                    label: 'Tipo de consulta',
                    hintText: 'Primera vez',
                  ),
                  SwitchCard(
                    primaryLabel: 'Embarazo',
                    secondaryLabel: 'PACIENTE GESTANTE',
                    onChanged: (bool newValue) {},
                  ),
                  SwitchCard(
                    primaryLabel: 'Menor de 18',
                    secondaryLabel: 'REQUIERE TUTOR',
                    onChanged: (bool newValue) {},
                  ),
                ],
              ),
            ),
            SectionCard(
              sectionName: 'Contexto Social',
              sectionIcon: Icons.groups,
              childWidget: Column(spacing: 15, children: [
                        CustomTextField(label: 'Motivo de interconsulta',
                        hintText: 'Describa el motivo médico o personal...',
                        maxLines: 2,
                        ),
                        CustomTextField(
                          label: 'Ocupación'
                        ),
                        CustomTextField(
                          label: 'Escolaridad'
                        ),
                        CustomTextField(
                          label: 'Red de apoyo'
                        ),
                      ],
                    ),
            ),
            SectionCard(
              background: Theme.of(context).canvasColor,
              sectionName: 'Antecedentes de Salud',
              sectionIcon: Icons.assignment_ind,
              childWidget: Column(
              spacing: 15,
              children: [
                ClosedEndedQuestion(
                  label: 'ORIENTACIÓN PREVIA',
                  question: '¿Ha recibido asesoría nutricional antes?'),
                CustomExpansionTile(
                  primaryLabel: 'Heredofamiliares', 
                  secondaryLabel: "Diabetes, Hipertensión, etc.",
                  icon: Icons.family_restroom,
                  tiles: ['Diabetes Mellitus','Hipertensioón Arterial','Obesidad','Cáncer','Dislipedmias'],
                ),
                CustomExpansionTile(
                  primaryLabel: 'Personales Patológicos', 
                  secondaryLabel: "Enfermedades, alergias, etc.",
                  icon: Icons.family_restroom,
                  childrenWidgets: [
                    Column(
                      spacing: 15,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChipsCard(
                          question: "¿Padece alguna enfermedad actualmente?",
                          chipsList: ['Gastritis', 'Colitis', 'Diabetes', 'Hipotiroidismo'],
                        ),
                        const CustomTextField(
                          label: "Alergias o Intolerancias",
                          hintText: "Ej. Nueces, Lactosa, Gluten...",
                        ),
                        const CustomTextField(
                          label: "Medicamentos actuales",
                          hintText: "Nombre y dosis (ej. Metformina 500mg)",
                        ),
                        SwitchCard(
                          primaryLabel: 'Consumo de tabaco/Alcohol', 
                          onChanged: (bool newValue) {},
                        )
                      ],
                    )
                  ],
                ), 
              ],
            )),
          ],
        ),
      ),
    );
  }
}
