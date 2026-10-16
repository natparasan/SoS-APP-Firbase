import 'package:flutter/material.dart';
import 'package:sos_alert_package/sos_alert_package.dart';

/// A segmented pill toggle for choosing between the "User" and
/// "Monitor" roles on the login/register screens.
class RoleToggle extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  const RoleToggle({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: UserRole.values.map((role) {
          final isSelected = role == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      role == UserRole.user ? Icons.person : Icons.shield_moon,
                      size: 18,
                      color: isSelected ? const Color(0xFF7B2FF7) : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      role.label,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF7B2FF7) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
