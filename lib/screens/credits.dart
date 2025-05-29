import 'package:flutter/material.dart';
import 'package:code_hacker/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.blueGrey.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'CRÉDITOS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Para balancear el layout
                  ],
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'CODE HACKER',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildCreditItem(
                  icon: Icons.person,
                  title: 'DESARROLLADO POR',
                  description: 'Senlin (Johnson1255)',
                ),
                _buildCreditItem(
                  icon: Icons.code,
                  title: 'TECNOLOGÍAS',
                  description: 'Flutter, Dart',
                ),
                _buildCreditItem(
                  icon: Icons.music_note,
                  title: 'EFECTOS DE SONIDO',
                  description: 'Hanifi Şahin, Universfield, u_8g40a9z0la (Pixabay)',
                ),
                _buildCreditItem(
                  icon: Icons.code_rounded,
                  title: 'GITHUB',
                  description: '@Johnson1255 (a.k.a. Senlin)',
                  isLink: true,
                  url: 'https://github.com/Johnson1255',
                ),
                _buildCreditItem(
                  icon: Icons.integration_instructions,
                  title: 'REPOSITORIO',
                  description: 'github.com/Johnson1255/CodeHacker',
                  isLink: true,
                  url: 'https://github.com/Johnson1255/CodeHacker',
                ),
                const Spacer(),
                const Center(
                  child: Text(
                    'Hecho con ❤️ y mucho café',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    '© 2025 Code Hacker',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                HackerButton(
                  text: 'VOLVER AL MENÚ',
                  icon: Icons.home,
                  isOutlined: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditItem({
    required IconData icon,
    required String title,
    required String description,
    bool isLink = false,
    String? url,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade700),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                isLink
                    ? GestureDetector(
                        onTap: () {
                          if (url != null) {
                            _launchURL(url);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              description,
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.open_in_new,
                              color: Colors.cyanAccent,
                              size: 14,
                            ),
                          ],
                        ),
                      )
                    : Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
