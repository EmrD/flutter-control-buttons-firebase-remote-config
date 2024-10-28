import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: dotenv.env["apiKey"] ?? "",
        appId: dotenv.env["appId"] ?? "",
        messagingSenderId: dotenv.env["messagingSenderId"] ?? "",
        projectId: dotenv.env["projectId"] ?? "",
        storageBucket: dotenv.env["storageBucket"] ?? ""),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Remote Config Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Firebase Remote Config Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final FirebaseRemoteConfig _remoteConfig;
  bool _isButtonEnabled = true;

  static const SnackBar snackbar = SnackBar(
      content:
          Text('This is a snackbar and comes from Firebase Remote Config'));
  // ignore: constant_identifier_names
  static const SnackBar error_snackbar = SnackBar(
      content: Text('Error fetching values from Firebase Remote Config'));

  @override
  void initState() {
    super.initState();
    _remoteConfig = FirebaseRemoteConfig.instance;
    _fetchRemoteConfig();
  }

  Future<void> _fetchRemoteConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 20),
      minimumFetchInterval: const Duration(minutes: 1),
    ));

    try {
      await _remoteConfig.setDefaults(<String, dynamic>{
        'snack_bar_button_visible': true,
      });
      await _remoteConfig.fetchAndActivate();
      setState(() {
        _isButtonEnabled = _remoteConfig.getBool('snack_bar_button_visible');
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${error_snackbar.content} ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "If you set up the value of the variable to true, you must see the button.",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Visibility(
              visible: _isButtonEnabled,
              child: TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).showSnackBar(snackbar),
                child: const Text('Show Snackbar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
