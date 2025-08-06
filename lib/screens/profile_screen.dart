import 'package:flutter/material.dart';
import 'package:todo_app_gelismis/model/user_model.dart';
import 'package:todo_app_gelismis/database/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserById(widget.userId);
      
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kullanıcı bilgileri yüklenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profil',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFFFFF176),
          elevation: 2,
          centerTitle: true,
        ),
        backgroundColor: const Color(0xFFFFF9C4),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueGrey,
                ),
              )
            : _user == null
                ? const Center(
                    child: Text(
                      'Kullanıcı bulunamadı',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profil Avatar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Kullanıcı Bilgileri
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Ad Soyad
                              _buildInfoRow(
                                icon: Icons.person,
                                label: 'Ad Soyad',
                                value: _user!.fullName,
                              ),
                              const Divider(height: 30),

                              // Kullanıcı Adı
                              _buildInfoRow(
                                icon: Icons.account_circle,
                                label: 'Kullanıcı Adı',
                                value: _user!.username,
                              ),
                              const Divider(height: 30),

                              // Kayıt Tarihi
                              _buildInfoRow(
                                icon: Icons.calendar_today,
                                label: 'Kayıt Tarihi',
                                value: '${_user!.createdAt.day}/${_user!.createdAt.month}/${_user!.createdAt.year}',
                              ),
                              const Divider(height: 30),

                              // Kayıt Saati
                              _buildInfoRow(
                                icon: Icons.access_time,
                                label: 'Kayıt Saati',
                                value: '${_user!.createdAt.hour.toString().padLeft(2, '0')}:${_user!.createdAt.minute.toString().padLeft(2, '0')}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // İstatistikler
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'İstatistikler',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 20),
                              FutureBuilder<List<int>>(
                                future: _loadStatistics(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blueGrey,
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return const Text(
                                      'İstatistikler yüklenemedi',
                                      style: TextStyle(color: Colors.red),
                                    );
                                  }

                                  final stats = snapshot.data ?? [0, 0, 0];
                                  return Column(
                                    children: [
                                      _buildStatRow(
                                        icon: Icons.task,
                                        label: 'Toplam Görev',
                                        value: stats[0].toString(),
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildStatRow(
                                        icon: Icons.check_circle,
                                        label: 'Tamamlanan Görev',
                                        value: stats[1].toString(),
                                        color: Colors.green,
                                      ),
                                      const SizedBox(height: 15),
                                      _buildStatRow(
                                        icon: Icons.pending,
                                        label: 'Bekleyen Görev',
                                        value: stats[2].toString(),
                                        color: Colors.orange,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Çıkış Yap Butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                            ),
                            child: const Text('Çıkış Yap'),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blueGrey,
            size: 24,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<List<int>> _loadStatistics() async {
    try {
      final dbHelper = DatabaseHelper();
      final allTodos = await dbHelper.getTodosByUserId(widget.userId);
      final doneTodos = await dbHelper.getDoneTodosByUserId(widget.userId);
      final activeTodos = await dbHelper.getActiveTodosByUserId(widget.userId);

      return [
        allTodos.length,
        doneTodos.length,
        activeTodos.length,
      ];
    } catch (e) {
      return [0, 0, 0];
    }
  }
} 