import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/clinic.dart';
import 'initials_avatar.dart';

/// Card de clínica (`.clinic-card` do CSS original): avatar, distância,
/// avaliação, tags de especialidades e botão "Agendar Consulta".
class ClinicCard extends StatelessWidget {
  const ClinicCard({super.key, required this.clinic, required this.onBook});

  final Clinic clinic;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(name: clinic.name, outlined: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 15,
                            color: AppColors.textDark,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              clinic.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.star,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            clinic.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.star,
                            ),
                          ),
                        ],
                      ),
                      if (clinic.phone.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.call_outlined,
                              size: 14,
                              color: AppColors.textGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              clinic.phone,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final String specialty in clinic.specialties)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onBook,
                child: const Text('Agendar Consulta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
