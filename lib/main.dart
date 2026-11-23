import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PreslocApp());
}

class PreslocApp extends StatefulWidget {
  const PreslocApp({super.key});

  @override
  State<PreslocApp> createState() => _PreslocAppState();
}

class _PreslocAppState extends State<PreslocApp> {
  Widget home =
      const Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('presloc_role');
    if (!mounted) return;
    setState(() {
      home = role == 'Guru BK'
          ? const GuruShell()
          : role == 'Siswa'
              ? const StudentShell()
              : const LoginScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PRESLOC',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8F1828)),
        fontFamily: 'Roboto',
      ),
      home: home,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = 'Siswa';
  bool obscurePassword = true;
  final TextEditingController identityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    identityController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (identityController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email/NIS dan kata sandi wajib diisi')),
      );
      return;
    }
    final identity = identityController.text.trim();
    final password = passwordController.text;
    final validSiswa =
        role == 'Siswa' && identity == '0064629105' && password == '123456';
    final validGuru =
        role == 'Guru BK' && identity == 'guru@presloc' && password == '123456';
    if (!validSiswa && !validGuru) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identitas atau kata sandi tidak valid')),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('presloc_role', role);
    await prefs.setString('presloc_identity', identity);
    if (!mounted) return;
    final destination =
        role == 'Guru BK' ? const GuruShell() : const StudentShell();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8F1828),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'PRESLOC',
                  style: TextStyle(
                    color: Color(0xFF7C1623),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Absensi & Pemantauan Lokasi Siswa',
                  style: TextStyle(color: Color(0xFF7A7F89), fontSize: 12),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Masuk ke Sistem',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Silakan masukkan identitas akun Anda',
                style: TextStyle(color: Color(0xFF858A93)),
              ),
              const SizedBox(height: 18),
              _RoleSelector(
                role: role,
                onChanged: (value) => setState(() => role = value),
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Email / NIS'),
              const SizedBox(height: 8),
              _InputField(
                hint: 'Masukkan Email atau NIS',
                icon: Icons.person_outline_rounded,
                controller: identityController,
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Kata Sandi'),
              const SizedBox(height: 8),
              _InputField(
                hint: 'Masukkan kata sandi',
                icon: Icons.lock_outline_rounded,
                obscure: obscurePassword,
                controller: passwordController,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9A9EA6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: login,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8F1828),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MASUK',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  'PORTAL RESMI SISWA SEKOLAH',
                  style: TextStyle(
                    color: Color(0xFFB0B3BA),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
                role: role,
                onChanged: (value) => setState(() => role = value),
              ),
              const SizedBox(height: 18),
              _FieldLabel('Email / NIS'),
              const SizedBox(height: 8),
              const _InputField(
                hint: 'Masukkan Email atau NIS',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              _FieldLabel('Kata Sandi'),
              const SizedBox(height: 8),
              _InputField(
                hint: 'Masukkan kata sandi',
                icon: Icons.lock_outline_rounded,
                obscure: obscurePassword,
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => obscurePassword = !obscurePassword),
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9A9EA6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: login,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8F1828),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MASUK',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Center(
                child: Text(
                  'PORTAL RESMI SISWA SEKOLAH',
                  style: TextStyle(
                    color: Color(0xFFB0B3BA),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.role, required this.onChanged});

  final String role;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Siswa', 'Guru BK'].map((value) {
          final active = role == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF8F1828) : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF777C85),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4E535C),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.controller,
  });

  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB1B4BA), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF9A9EA6), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
        ),
      ),
    );
  }
}

class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int index = 0;

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('presloc_role');
    await prefs.remove('presloc_identity');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const StudentHomePage(),
      const AttendancePage(),
      const MapPage(),
      ProfilePage(onLogout: logout),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: _BottomBar(
        index: index,
        labels: const ['Beranda', 'Presensi', 'Peta', 'Profil'],
        icons: const [
          Icons.grid_view_rounded,
          Icons.location_on_outlined,
          Icons.map_outlined,
          Icons.person_outline_rounded,
        ],
        onTap: (value) => setState(() => index = value),
      ),
    );
  }
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String qrData = 'PRESLOC|0064629105';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          children: [
            const _TopHeader(title: 'Beranda Siswa'),
            const SizedBox(height: 16),
            _StudentCard(),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.qr_code_rounded,
                    title: 'QR Berhasil',
                    value: 'Siap Dipindai',
                    color: Color(0xFFE8F3FF),
                    iconColor: Color(0xFF2C78A7),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.timer_outlined,
                    title: 'Kedaluwarsa',
                    value: '02:42',
                    color: Color(0xFFFFF1EA),
                    iconColor: Color(0xFFD6753B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE9EBEE)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 190,
                    height: 190,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE3E5E8)),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tunjukkan QR ke Guru saat Masuk atau Pulang',
                    style: TextStyle(
                      color: Color(0xFF8A8E96),
                      fontSize: 11,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        qrData =
                            'PRESLOC|0064629105|${DateTime.now().millisecondsSinceEpoch}';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Kode QR telah diperbarui')),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                    label: const Text('Perbarui Kode QR'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const _InfoCard(),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.title, this.onLogout});
  final String title;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF8F1828),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const Text(
                'PRESLOC',
                style: TextStyle(
                  color: Color(0xFF8F1828),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada notifikasi baru')),
            );
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF4E535C),
          ),
        ),
        if (onLogout != null)
          IconButton(
            tooltip: 'Keluar',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF4E535C)),
          )
        else
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF7D1A27),
            child: Text(
              'AF',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF961C2D), Color(0xFF74121E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFF1D9DE),
            child: Text(
              'AF',
              style: TextStyle(
                color: Color(0xFF7D1A27),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KARTU SISWA',
                  style: TextStyle(
                    color: Color(0xFFFFD4DA),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Ahmad Fauzan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'XI RPL 1  •  NIS 0064629105',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EBEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF979BA3),
                    fontSize: 9,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EBEE)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.event_available, color: Color(0xFF8F1828), size: 20),
              SizedBox(width: 8),
              Text('Status Kehadiran',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              Spacer(),
              Chip(
                label: Text('Hadir',
                    style: TextStyle(
                        color: Color(0xFF2C9A63),
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                backgroundColor: Color(0xFFEAF6EF),
                side: BorderSide.none,
              ),
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeInfo(title: 'Jam Masuk', time: '06:48 WIB'),
              _TimeInfo(title: 'Jam Pulang', time: '--:-- WIB'),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.my_location_rounded,
                  color: Color(0xFF2C9A63), size: 18),
              SizedBox(width: 7),
              Text('Status Lokasi: ',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              Text('Aktif',
                  style: TextStyle(
                      color: Color(0xFF2C9A63), fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  const _TimeInfo({required this.title, required this.time});
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Color(0xFF92969E), fontSize: 11)),
        const SizedBox(height: 4),
        Text(time,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }
}

class GuruShell extends StatefulWidget {
  const GuruShell({super.key});

  @override
  State<GuruShell> createState() => _GuruShellState();
}

class _GuruShellState extends State<GuruShell> {
  int index = 0;

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('presloc_role');
    await prefs.remove('presloc_identity');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      GuruDashboard(
        onNavigate: (value) => setState(() => index = value),
        onLogout: logout,
      ),
      const ScanPage(),
      const MapPage(),
      const AttendancePage(),
      const WarningPage(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: index < 4
          ? _BottomBar(
              index: index,
              labels: const [
                'Beranda',
                'Scan',
                'Peta',
                'Presensi',
              ],
              icons: const [
                Icons.grid_view_rounded,
                Icons.qr_code_scanner_rounded,
                Icons.map_outlined,
                Icons.people_outline_rounded,
              ],
              onTap: (value) => setState(() => index = value),
            )
          : null,
    );
  }
}

class GuruDashboard extends StatelessWidget {
  const GuruDashboard({
    super.key,
    required this.onNavigate,
    required this.onLogout,
  });

  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopHeader(title: 'Dashboard Guru BK', onLogout: onLogout),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9A1F30), Color(0xFF72131F)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELAMAT PAGI',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                  Text('Ibu Dra. Siti Rahayu',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 3),
                  Text('Koordinator Bimbingan Konseling',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Ringkasan Kehadiran Hari Ini',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                    child: _SummaryCard(
                        value: '842',
                        title: 'Hadir',
                        color: Color(0xFFE8F6EE))),
                SizedBox(width: 8),
                Expanded(
                    child: _SummaryCard(
                        value: '18',
                        title: 'Di Luar Area',
                        color: Color(0xFFFFEFEA))),
                SizedBox(width: 8),
                Expanded(
                    child: _SummaryCard(
                        value: '7',
                        title: 'Belum Aktif',
                        color: Color(0xFFF7F1E8))),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Menu Pemantauan BK',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.28,
              children: [
                _MenuCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Scan QR Siswa',
                    subtitle: 'Masuk / pulang',
                    page: 1,
                    onTap: onNavigate),
                _MenuCard(
                    icon: Icons.radar_rounded,
                    title: 'Peta Radius',
                    subtitle: 'Pantau lokasi',
                    page: 2,
                    onTap: onNavigate),
                _MenuCard(
                    icon: Icons.assignment_rounded,
                    title: 'Daftar Kehadiran',
                    subtitle: 'Data & rekayasa',
                    page: 3,
                    onTap: onNavigate),
                _MenuCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'Log Peringatan',
                    subtitle: 'Cek status',
                    page: 4,
                    onTap: onNavigate),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFB12636)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PERINGATAN TERKINI',
                            style: TextStyle(
                                color: Color(0xFFB12636),
                                fontWeight: FontWeight.w800,
                                fontSize: 11)),
                        Text('2 siswa terdeteksi di luar radius sekolah',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.value,
    required this.title,
    required this.color,
  });
  final String value;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF30343A))),
          const SizedBox(height: 3),
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF757A82),
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.page,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int page;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(page),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9EBEE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF8F1828),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 21),
            ),
            const Spacer(),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF9A9DA4), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.index,
    required this.labels,
    required this.icons,
    required this.onTap,
  });

  final int index;
  final List<String> labels;
  final List<IconData> icons;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EA))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(labels.length, (item) {
              final active = index == item;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(item),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[item],
                        color: active
                            ? const Color(0xFF8F1828)
                            : const Color(0xFF8E9299),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[item],
                        style: TextStyle(
                          color: active
                              ? const Color(0xFF8F1828)
                              : const Color(0xFF8E9299),
                          fontSize: 10,
                          fontWeight:
                              active ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dark = Color(0xFF25272B);
    const red = Color(0xFF8F1828);
    final paint = Paint()..color = dark;

    final unit = size.width / 21;
    final modules = <List<int>>[
      [1, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 1],
    ];

    for (var row = 0; row < modules.length; row++) {
      for (var col = 0; col < modules[row].length; col++) {
        if (modules[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(col * unit, row * unit, unit * .82, unit * .82),
            paint,
          );
        }
      }
    }
    for (var row = 0; row < modules.length; row++) {
      for (var col = 0; col < modules[row].length; col++) {
        if (modules[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              (14 + col) * unit,
              row * unit,
              unit * .82,
              unit * .82,
            ),
            paint,
          );
        }
      }
    }
    for (var row = 0; row < modules.length; row++) {
      for (var col = 0; col < modules[row].length; col++) {
        if (modules[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * unit,
              (14 + row) * unit,
              unit * .82,
              unit * .82,
            ),
            paint,
          );
        }
      }
    }

    final randomBlocks = [
      [9, 2],
      [11, 2],
      [8, 4],
      [10, 5],
      [12, 4],
      [9, 7],
      [12, 8],
      [15, 9],
      [17, 10],
      [9, 11],
      [11, 12],
      [13, 12],
      [16, 13],
      [18, 15],
      [11, 16],
      [13, 18],
      [15, 17],
      [17, 19],
      [8, 14],
      [5, 9],
      [3, 12],
      [6, 16],
    ];
    for (final block in randomBlocks) {
      canvas.drawRect(
        Rect.fromLTWH(
          block[0] * unit,
          block[1] * unit,
          unit * .82,
          unit * .82,
        ),
        paint,
      );
    }

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, unit * 2.2, Paint()..color = Colors.white);
    canvas.drawCircle(center, unit * 1.65, Paint()..color = red);
    canvas.drawCircle(
      center,
      unit * .65,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final TextEditingController searchController = TextEditingController();
  String query = '';

  final students = const [
    ('BP', 'Bagas Pratama', '06:45', 'Presensi', true),
    ('DN', 'Dina Novita', '06:52', 'Di Luar Area', false),
    ('FA', 'Fajar Alamsyah', '07:10', 'Belum Absen', null),
    ('SA', 'Salma Aulia', '06:40', 'Hadir', true),
    ('RP', 'Rizky Perdana', '07:10', 'Tidak Terpantau', false),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = students.where((item) {
      final normalized = '${item.$1} ${item.$2} ${item.$3}'.toLowerCase();
      return normalized.contains(query.toLowerCase());
    }).toList();
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: _PageHeader(title: 'Daftar Kehadiran'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIS',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E4E8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.$5 == false
                          ? const Color(0xFFF2B4BB)
                          : const Color(0xFFE9EBEE),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: item.$5 == false
                            ? const Color(0xFFF8DDE1)
                            : const Color(0xFFF1F2F4),
                        child: Text(item.$1,
                            style: const TextStyle(
                                color: Color(0xFF7D1A27),
                                fontWeight: FontWeight.w800,
                                fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 13)),
                            const SizedBox(height: 3),
                            Text('Masuk ${item.$3}',
                                style: const TextStyle(
                                    color: Color(0xFF858A92), fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                          item.$5 == true
                              ? 'Hadir'
                              : item.$5 == false
                                  ? 'Kritis'
                                  : 'Belum',
                          style: TextStyle(
                              color: item.$5 == false
                                  ? const Color(0xFFB12636)
                                  : const Color(0xFF2C9A63),
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF8F1828),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
      ],
    );
  }
}

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String mode = 'Masuk';
  String scannedIdentity = '';
  MobileScannerController? scannerController;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
      );
    }
  }

  @override
  void dispose() {
    scannerController?.dispose();
    super.dispose();
  }

  Future<void> confirmAttendance() async {
    if (scannedIdentity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pindai QR siswa terlebih dahulu')),
      );
      return;
    }
    final attendanceTime = TimeOfDay.now().format(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('presloc_attendance', scannedIdentity);
    await prefs.setString('presloc_attendance_mode', mode);
    await prefs.setString('presloc_attendance_time', attendanceTime);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Presensi $mode berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PageHeader(title: 'Scan QR Siswa'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => setState(() => mode = 'Masuk'),
                    style: FilledButton.styleFrom(
                      backgroundColor: mode == 'Masuk'
                          ? const Color(0xFF8F1828)
                          : const Color(0xFFB7BAC0),
                    ),
                    child: const Text('Masuk'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => mode = 'Pulang'),
                    child: const Text('Pulang'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF30343A),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: scannerController == null
                  ? const Center(
                      child: Text(
                        'Pemindai kamera tersedia pada Android/iOS',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : MobileScanner(
                      controller: scannerController!,
                      onDetect: (capture) {
                        final barcode = capture.barcodes.isEmpty
                            ? null
                            : capture.barcodes.first;
                        final value = barcode?.rawValue;
                        if (value != null &&
                            value.contains('PRESLOC') &&
                            scannedIdentity != value) {
                          setState(() => scannedIdentity = value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('QR siswa berhasil dipindai'),
                            ),
                          );
                        }
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9EBEE)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFF1D9DE),
                    child: Text('RN',
                        style: TextStyle(
                            color: Color(0xFF7D1A27),
                            fontWeight: FontWeight.w800)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Radhya Nugraha',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        Text('XI MPLB 1  •  NIS 0064629105',
                            style: TextStyle(
                                color: Color(0xFF858A92), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: confirmAttendance,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8F1828),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Konfirmasi Presensi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class ScanPageOld extends StatelessWidget {
  const ScanPageOld({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PageHeader(title: 'Scan QR Siswa'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8F1828),
                    ),
                    child: const Text('Masuk'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Pulang'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF30343A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Arahkan kamera ke QR Code siswa',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9EBEE)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFFF1D9DE),
                    child: Text('RN',
                        style: TextStyle(
                            color: Color(0xFF7D1A27),
                            fontWeight: FontWeight.w800)),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Radhya Nugraha',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        Text('XI MPLB 1  •  NIS 0064629105',
                            style: TextStyle(
                                color: Color(0xFF858A92), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8F1828),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Konfirmasi Presensi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? position;
  bool loadingLocation = false;
  String locationStatus = 'Lokasi belum diperbarui';

  Future<void> updateLocation() async {
    setState(() => loadingLocation = true);
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        loadingLocation = false;
        locationStatus = 'Layanan lokasi perangkat tidak aktif';
      });
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        loadingLocation = false;
        locationStatus = 'Izin lokasi belum diberikan';
      });
      return;
    }
    final current = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    if (!mounted) return;
    setState(() {
      position = current;
      loadingLocation = false;
      locationStatus = 'Lokasi diperbarui ${TimeOfDay.now().format(context)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: _PageHeader(title: 'Peta Pemantauan'),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFEFE8DD),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: _MapPainter(),
                  ),
                  Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFB12636),
                          width: 3,
                        ),
                        color: const Color(0xFFB12636).withOpacity(.06),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 18,
                    left: 18,
                    child: Chip(
                      avatar:
                          Icon(Icons.radar, size: 18, color: Color(0xFF8F1828)),
                      label: Text('Radius Sekolah: 500m',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 18,
                    child: FilledButton.icon(
                      onPressed: loadingLocation ? null : updateLocation,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8F1828),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      icon: loadingLocation
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.my_location, size: 16),
                      label: const Text('Lokasi'),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFFF1D9DE),
                                child: Text('DN',
                                    style: TextStyle(
                                        color: Color(0xFF7D1A27),
                                        fontWeight: FontWeight.w800)),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dina Novita',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800)),
                                    Text('NIS 0062834',
                                        style: TextStyle(
                                            color: Color(0xFF858A92),
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text('Di Luar Area',
                                    style: TextStyle(
                                        color: Color(0xFFB12636), fontSize: 9)),
                                backgroundColor: Color(0xFFFFECEE),
                                side: BorderSide.none,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                              position == null
                                  ? 'Jarak ke sekolah: 320 meter'
                                  : 'Jarak ke sekolah: ${Geolocator.distanceBetween(position!.latitude, position!.longitude, -7.797068, 110.370529).round()} meter',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          Text(locationStatus,
                              style: TextStyle(
                                  color: Color(0xFF858A92), fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 16;
    final roadEdge = Paint()
      ..color = const Color(0xFFD7D3CA)
      ..strokeWidth = 20;

    canvas.drawLine(Offset(0, size.height * .48),
        Offset(size.width, size.height * .42), roadEdge);
    canvas.drawLine(Offset(0, size.height * .48),
        Offset(size.width, size.height * .42), road);
    canvas.drawLine(Offset(size.width * .47, 0),
        Offset(size.width * .53, size.height), roadEdge);
    canvas.drawLine(Offset(size.width * .47, 0),
        Offset(size.width * .53, size.height), road);

    final green = Paint()..color = const Color(0xFF56B582);
    final red = Paint()..color = const Color(0xFFB12636);
    final positions = [
      (Offset(size.width * .25, size.height * .28), green),
      (Offset(size.width * .68, size.height * .34), red),
      (Offset(size.width * .78, size.height * .24), green),
      (Offset(size.width * .18, size.height * .62), green),
      (Offset(size.width * .72, size.height * .62), red),
      (Offset(size.width * .42, size.height * .22), green),
    ];
    for (final item in positions) {
      canvas.drawCircle(item.$1, 9, item.$2);
      canvas.drawCircle(
          item.$1, 13, Paint()..color = item.$2.color.withOpacity(.25));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WarningPage extends StatelessWidget {
  const WarningPage({super.key});

  @override
  Widget build(BuildContext context) {
    const warnings = [
      ('Siswa keluar area sekolah (320m)', 'Dina Novita', '07:15 WIB', true),
      ('Siswa tidak terpantau 5 menit', 'Rizky Perdana', '09:30 WIB', false),
      ('Siswa keluar area sekolah (510m)', 'Faris Maulana', '08:45 WIB', true),
      ('Sinyal GPS lemah', 'Budi Santoso', '08:15 WIB', false),
    ];
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 14, 18, 10),
            child: _PageHeader(title: 'Peringatan'),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: warnings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = warnings[index];
                return Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.$4
                          ? const Color(0xFFF2B4BB)
                          : const Color(0xFFE9EBEE),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.$4
                              ? const Color(0xFFFFECEE)
                              : const Color(0xFFF2F3F5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.$4
                              ? Icons.warning_amber_rounded
                              : Icons.location_off_outlined,
                          color: item.$4
                              ? const Color(0xFFB12636)
                              : const Color(0xFF777C85),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 12)),
                            Text('${item.$2}  •  ${item.$3}',
                                style: const TextStyle(
                                    color: Color(0xFF858A92), fontSize: 10)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                            ),
                            builder: (_) => Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.$1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('${item.$2}  •  ${item.$3}'),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const Text('Detail',
                            style: TextStyle(
                                color: Color(0xFF8F1828),
                                fontSize: 11,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFFF1D9DE),
              child: Text('AF',
                  style: TextStyle(
                      color: Color(0xFF7D1A27),
                      fontSize: 24,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 12),
            const Text('Ahmad Fauzan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const Text('Siswa  •  XI RPL 1',
                style: TextStyle(color: Color(0xFF858A92))),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.badge_outlined),
                    title: Text('NIS'),
                    trailing: Text('0064629105'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Radius Sekolah'),
                    trailing: Text('500 meter'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout_rounded),
                    title: Text('Keluar'),
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
