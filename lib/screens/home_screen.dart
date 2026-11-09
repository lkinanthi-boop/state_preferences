import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: provider.isDarkMode ? 'Light Mode' : 'Dark Mode',
            onPressed: provider.toggleTheme,
          ),
        ],
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home, size: 80, color: Colors.deepPurple),

                    const SizedBox(height: 24),

                    Text(
                      'Jumlah kunjungan: ${provider.visitCount} kali',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      provider.user.isLoggedIn
                          ? 'Selamat datang, ${provider.user.name}!'
                          : 'Selamat datang, Tamu!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),

                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),
                    if (provider.user.isLoggedIn) ...[
                      Text(
                        'Email: ${provider.user.email}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },

                        icon: const Icon(Icons.person),
                        label: const Text('Lihat Profil'),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },

                        icon: const Icon(Icons.login),
                        label: const Text('Login / Daftar'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
