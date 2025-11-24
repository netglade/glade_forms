import 'package:flutter/material.dart';

class GladeFormsExtensionScreen extends StatefulWidget {
  const GladeFormsExtensionScreen({super.key});

  @override
  State<GladeFormsExtensionScreen> createState() => _GladeFormsExtensionScreenState();
}

class _GladeFormsExtensionScreenState extends State<GladeFormsExtensionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glade Forms Inspector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Glade Forms DevTools Extension',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inspect and debug your glade_forms models',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('View active GladeModel instances'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('Inspect input values and validation states'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('Monitor form dirty/pure states'),
                    ),
                    ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('Real-time updates as forms change'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
