import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/authProvider.dart';
import 'loginPage.dart';
import 'package:product_application/model/userModel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(
      authNotifierProvider.select((state) => state.user),
    );

    final isRefreshing = ref.watch(
      authNotifierProvider.select((state) => state.isRefreshingToken),
    );

    if (currentUser == null) {
      return const LoginPage();
    }
    Future<void> handleLogout() async {
      final confirm = await _buildShowDialog(context);
      if (confirm == true) {
        ref.read(authNotifierProvider.notifier).logout();
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profilim'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: handleLogout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange, Colors.orangeAccent],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildProfileHero(currentUser),
                  const SizedBox(height: 30),
                  _buildTextName(currentUser),
                  const SizedBox(height: 8),
                  _buildTextProfile(currentUser),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    icon: Icons.badge,
                    title: 'Kullanıcı ID',
                    value: currentUser.id?.toString() ?? '-',
                    color: Colors.orange,
                  ),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    title: 'Cinsiyet',
                    value: currentUser.gender == 'male'
                        ? 'Erkek'
                        : currentUser.gender == 'female'
                        ? 'Kadın'
                        : (currentUser.gender ?? '-'),
                    color: Colors.orange,
                  ),
                  _buildInfoCard(
                    icon: Icons.cake,
                    title: 'Yaş',
                    value: currentUser.age?.toString() ?? '-',
                    color: Colors.orange,
                  ),
                  _buildInfoCard(
                    icon: Icons.shield,
                    title: 'Rol',
                    value: currentUser.role ?? 'Kullanıcı',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  _buildContainerToken(isRefreshing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildContainerToken(bool isRefreshing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRefreshing ? Colors.yellow[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRefreshing ? Colors.yellow[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isRefreshing ? Icons.hourglass_empty : Icons.check_circle,
            color: isRefreshing ? Colors.yellow[900] : Colors.green[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRefreshing
                      ? 'Token Arka Planda Yenileniyor...'
                      : 'Oturum Aktif',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isRefreshing
                        ? Colors.yellow[900]
                        : Colors.green[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Token otomatik olarak her 30 dakikada bir yenilenir',
                  style: TextStyle(
                    fontSize: 12,
                    color: isRefreshing
                        ? Colors.yellow[700]
                        : Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          if (isRefreshing)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  isRefreshing ? Colors.yellow[700] : Colors.green[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Text _buildTextProfile(UserModel currentUser) {
    return Text(
      '@${currentUser.username ?? ''}',
      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
    );
  }

  Text _buildTextName(UserModel currentUser) {
    return Text(
      '${currentUser.firstName ?? ''} ${currentUser.lastName ?? ''}',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Hero _buildProfileHero(UserModel currentUser) {
    return Hero(
      tag: 'profile_image',
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey[300],
          backgroundImage: currentUser.image != null
              ? NetworkImage(currentUser.image!)
              : null,
          child: currentUser.image == null
              ? Icon(Icons.person, size: 70, color: Colors.grey[600])
              : null,
        ),
      ),
    );
  }

  Future<bool?> _buildShowDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
