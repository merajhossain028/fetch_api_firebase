import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Data Sync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // ignore: deprecated_member_use
  final DatabaseReference _firebaseRef = FirebaseDatabase.instance.reference();

  String _firebaseData = '';

  @override
  void dispose() {
    _apiKeyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the entered API key and password
      final apiKey = _apiKeyController.text;
      //final password = _passwordController.text;

      // Update Firebase configuration with the new API key
      final FirebaseOptions firebaseOptions = Firebase.app().options;
      final updatedOptions = FirebaseOptions(
        apiKey: apiKey,
        appId: firebaseOptions.appId,
        messagingSenderId: firebaseOptions.messagingSenderId,
        projectId: firebaseOptions.projectId,
        authDomain: firebaseOptions.authDomain,
        databaseURL: firebaseOptions.databaseURL,
        storageBucket: firebaseOptions.storageBucket,
      );
      await Firebase.initializeApp(options: updatedOptions);

      // Authenticate or perform any additional verification with the password

      // Fetch data from Firebase
      final snapshot = await _firebaseRef.once();
      final data = snapshot.snapshot.value;

      setState(() {
        _firebaseData = data.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Data Sync'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(labelText: 'Web API Key'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the API key';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the password';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            const Text('Firebase Data:'),
            const SizedBox(height: 10.0),
            Text(_firebaseData),
          ],
        ),
      ),
    );
  }
}
