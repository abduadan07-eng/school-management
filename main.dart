import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }
  runApp(const SchoolManagementApp());
}

class SchoolManagementApp extends StatelessWidget {
  const SchoolManagementApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'School Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
          useMaterial3: true,
        ),
        home: const LoginPage(),
      );
}

enum AccountRole { superAdmin, schoolAdmin, teacher, student, parent }

extension AccountRoleLabel on AccountRole {
  String get label => switch (this) {
        AccountRole.superAdmin => 'Super Admin',
        AccountRole.schoolAdmin => 'School Admin',
        AccountRole.teacher => 'Teacher',
        AccountRole.student => 'Student',
        AccountRole.parent => 'Parent',
      };
  IconData get icon => switch (this) {
        AccountRole.superAdmin => Icons.admin_panel_settings,
        AccountRole.schoolAdmin => Icons.account_balance,
        AccountRole.teacher => Icons.cast_for_education,
        AccountRole.student => Icons.school,
        AccountRole.parent => Icons.family_restroom,
      };
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AccountRole role = AccountRole.superAdmin;
  final identifier = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String message = '';

  bool get configured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  Future<void> login() async {
    if (!configured) {
      setState(() => message =
          'Supabase wali lama dejin. Ku dar SUPABASE_URL iyo SUPABASE_ANON_KEY gudaha GitHub Secrets.');
      return;
    }
    if (identifier.text.trim().isEmpty || password.text.isEmpty) {
      setState(() => message = 'Fadlan buuxi labada meelood.');
      return;
    }
    if (role != AccountRole.superAdmin) {
      setState(() => message =
          'Login-ka School users (code/identifier) wuxuu u baahan yahay in la dhammeystiro marka database-ka la diyaariyo.');
      return;
    }
    setState(() { busy = true; message = ''; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: identifier.text.trim(),
        password: password.text,
      );
      if (mounted) {
        setState(() => message = 'Login waa guuleystay. Dashboard-ka xiga ayaa la dhisayaa.');
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => message = e.message);
    } catch (_) {
      if (mounted) setState(() => message = 'Wax khalad ah ayaa dhacay. Mar kale isku day.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    identifier.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuper = role == AccountRole.superAdmin;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_balance, size: 58, color: Color(0xFF176B5B)),
                  const SizedBox(height: 12),
                  Text('SCHOOL MANAGEMENT',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Hal app • Dugsiyo badan', textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  Text('Dooro account-ka', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...AccountRole.values.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() { role = r; message = ''; }),
                      icon: Icon(r.icon),
                      label: Text(r.label),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        backgroundColor: role == r ? const Color(0xFFE4F2ED) : null,
                      ),
                    ),
                  )),
                  const SizedBox(height: 14),
                  Text(isSuper ? 'Email' : 'School Access Code / Identifier'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: identifier,
                    keyboardType: isSuper ? TextInputType.emailAddress : TextInputType.text,
                    decoration: InputDecoration(
                      hintText: isSuper ? 'admin@example.com' : 'Geli code-kaaga',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Password'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: busy ? null : login,
                    child: Text(busy ? 'Sug...' : 'LOGIN'),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 18),
                  const Text('Starter v0.1 • Dashboard-yada iyo modules-ka waxaa lagu dari doonaa wejiyada xiga.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
