import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Data Sync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    final password = _passwordController.text;

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
        title: Text('Firebase Data Sync'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(labelText: 'Web API Key'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the API key';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
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
                    child: Text('Save Settings'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Text('Firebase Data:'),
            SizedBox(height: 10.0),
            Text(_firebaseData),
          ],
        ),
      ),
    );
  }
  
}

