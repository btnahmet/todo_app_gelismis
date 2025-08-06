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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isTablet = width > 600;
    final isLandscape = width > height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Profil',
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
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
                ? Center(
                    child: Text(
                      'Kullanıcı bulunamadı',
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        color: Colors.blueGrey,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 32 : 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: height,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: isLandscape ? height * 0.02 : height * 0.05),
                            
                            // Profil Container
                            Container(
                              width: isTablet ? width * 0.6 : double.infinity,
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 600 : double.infinity,
                              ),
                              child: Column(
                                children: [
                                  // Profil Avatar
                                  Container(
                                    width: isTablet ? 150 : 120,
                                    height: isTablet ? 150 : 120,
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
                                    child: Icon(
                                      Icons.person,
                                      size: isTablet ? 80 : 60,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  
                                  SizedBox(height: isTablet ? 40 : 30),

                                  // Kullanıcı Bilgileri
                                  Container(
                                    padding: EdgeInsets.all(isTablet ? 28 : 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
                                          isTablet: isTablet,
                                        ),
                                        Divider(height: isTablet ? 40 : 30),

                                        // Kullanıcı Adı
                                        _buildInfoRow(
                                          icon: Icons.account_circle,
                                          label: 'Kullanıcı Adı',
                                          value: _user!.username,
                                          isTablet: isTablet,
                                        ),
                                        Divider(height: isTablet ? 40 : 30),

                                        // Kayıt Tarihi
                                        _buildInfoRow(
                                          icon: Icons.calendar_today,
                                          label: 'Kayıt Tarihi',
                                          value: '${_user!.createdAt.day}/${_user!.createdAt.month}/${_user!.createdAt.year}',
                                          isTablet: isTablet,
                                        ),
                                        Divider(height: isTablet ? 40 : 30),

                                        // Kayıt Saati
                                        _buildInfoRow(
                                          icon: Icons.access_time,
                                          label: 'Kayıt Saati',
                                          value: '${_user!.createdAt.hour.toString().padLeft(2, '0')}:${_user!.createdAt.minute.toString().padLeft(2, '0')}',
                                          isTablet: isTablet,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: isTablet ? 40 : 30),

                                  // İstatistikler
                                  Container(
                                    padding: EdgeInsets.all(isTablet ? 28 : 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
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
                                        Text(
                                          'İstatistikler',
                                          style: TextStyle(
                                            fontSize: isTablet ? 24 : 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                        SizedBox(height: isTablet ? 28 : 20),
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
                                              return Text(
                                                'İstatistikler yüklenemedi',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: isTablet ? 18 : 16,
                                                ),
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
                                                  isTablet: isTablet,
                                                ),
                                                SizedBox(height: isTablet ? 20 : 15),
                                                _buildStatRow(
                                                  icon: Icons.check_circle,
                                                  label: 'Tamamlanan Görev',
                                                  value: stats[1].toString(),
                                                  color: Colors.green,
                                                  isTablet: isTablet,
                                                ),
                                                SizedBox(height: isTablet ? 20 : 15),
                                                _buildStatRow(
                                                  icon: Icons.pending,
                                                  label: 'Bekleyen Görev',
                                                  value: stats[2].toString(),
                                                  color: Colors.orange,
                                                  isTablet: isTablet,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: isTablet ? 40 : 30),

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
                                        padding: EdgeInsets.symmetric(
                                          vertical: isTablet ? 20 : 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isTablet ? 35 : 30),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: Text(
                                        'Çıkış Yap',
                                        style: TextStyle(
                                          fontSize: isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: isLandscape ? height * 0.02 : height * 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          ),
          child: Icon(
            icon,
            color: Colors.blueGrey,
            size: isTablet ? 32 : 24,
          ),
        ),
        SizedBox(width: isTablet ? 20 : 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: isTablet ? 6 : 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
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
    required bool isTablet,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          ),
          child: Icon(
            icon,
            color: color,
            size: isTablet ? 32 : 24,
          ),
        ),
        SizedBox(width: isTablet ? 20 : 15),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.blueGrey,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 8 : 6,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
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