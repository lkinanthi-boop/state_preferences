import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _favoriteController = TextEditingController();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inisialisasi controller di sini aman karena context sudah siap
    if (!_isInitialized) {
      final provider = context.watch<UserProvider>();
      _nameController = TextEditingController(text: provider.user.name);
      _emailController = TextEditingController(text: provider.user.email);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Menyimpan profil dengan validasi keamanan
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    // Validasi karakter berbahaya pada nama
    final dangerousCharacter = RegExp(r'[<>]');

    if (dangerousCharacter.hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama tidak boleh mengandung karakter berbahaya seperti < atau >',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<UserProvider>();
    final prefs = await SharedPreferences.getInstance();

    // Mengecek email yang sudah digunakan
    final registeredEmail = prefs.getString('user_email');

    if (registeredEmail != null &&
        registeredEmail.toLowerCase() == email.toLowerCase() &&
        (!provider.user.isLoggedIn ||
            registeredEmail.toLowerCase() !=
                provider.user.email.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sudah digunakan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Memperbarui data pengguna
    final updatedUser = provider.user.copyWith(
      name: name,
      email: email,
      isLoggedIn: true,
    );

    await provider.updateUser(updatedUser);

    // Menyimpan email untuk simulasi pengecekan email terdaftar
    await prefs.setString('user_email', email);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Menambahkan hobi ke daftar favorit
  void _addFavorite() {
    final item = _favoriteController.text.trim();

    if (item.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hobi tidak boleh kosong')));
      return;
    }

    final provider = context.read<UserProvider>();
    if (provider.favorites.contains(item)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hobi sudah ada di daftar favorit')),
      );
      return;
    }

    provider.addFavorite(item);
    _favoriteController.clear();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(
                          Icons.person,
                          size: 60,

                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Daftar Favorit - Latihan 3
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Daftar Favorit (Hobi)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              TextField(
                                controller: _favoriteController,
                                decoration: const InputDecoration(
                                  labelText: 'Hobi favorit',
                                  hintText: 'Contoh: Membaca',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _addFavorite(),
                              ),

                              const SizedBox(height: 8),

                              ElevatedButton.icon(
                                onPressed: _addFavorite,
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Favorit'),
                              ),

                              const SizedBox(height: 12),

                              if (provider.favorites.isEmpty)
                                const Text(
                                  'Belum ada favorit yang ditambahkan.',
                                )
                              else
                                ...provider.favorites.map(
                                  (favorite) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(Icons.favorite),
                                    title: Text(favorite),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Hapus favorit',
                                      onPressed: () {
                                        provider.removeFavorite(favorite);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),

                        keyboardType: TextInputType.emailAddress,

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }

                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Format email tidak valid';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Profil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Card(
                        color: Colors.amber[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: Colors.amber[800]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Catatan Keamanan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'Data disimpan di SharedPreferences (plaintext). '
                                'Jangan simpan password atau data sensitif di sini. '
                                'Gunakan secure storage untuk data sensitif.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
