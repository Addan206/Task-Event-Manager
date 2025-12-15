import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 221, 217, 217),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "TASK\nMANAGER",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 40),
              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LargeButton(
                    color: const  Color(0xFF3A0D9A),
                    icon: Icons.list,
                    label: "Tasks",
                    onTap: () => Navigator.pushNamed(context, "/tasks"),

                  ),
                  const SizedBox(width: 20),
                  LargeButton(
                    color: const Color(0xFF871515),
                    icon: Icons.event,
                    label: "Events",
                    onTap: () => Navigator.pushNamed(context, "/events"),

                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// LARGE SQUARE BUTTON
class LargeButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const LargeButton({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.32;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}