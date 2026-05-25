import 'package:flutter/material.dart';

class TermsAndPrivacyScreen extends StatelessWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Privacy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Use & Privacy Notice',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: May 25, 2026',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Authorized Use Only',
              'This application is the exclusive property of National Irrigation Administration PIMO and is intended solely for use by authorized employees. By accessing this app, you confirm that you are a current, authorized employee and agree to use it only for official company purposes.',
            ),

            _buildSection(
              '2. Data We Collect',
              'When you capture an image using this app, the following data is automatically recorded and submitted:\n\n'
                  '📍 Location — Your GPS coordinates at the time the photo is taken\n'
                  '🕐 Date & Time — The exact timestamp of the captured image\n'
                  '🖼️ Image — The photo itself as captured by your device camera\n\n'
                  'No other data is collected from your device.',
            ),

            _buildSection(
              '3. How Your Data Is Used',
              'Collected data is used strictly for field attendance monitoring and location verification, to confirm that photos are captured on-site and at the correct time during field operations. It will not be used for personal profiling or sold to any third party.',
            ),

            _buildSection(
              '4. Data Storage',
              'All data is initially stored on your device and automatically uploaded to National Irrigation Administration PIMO\'s internal servers once internet connectivity is available. It will not be transmitted to any external or third-party platform.',
            ),

            _buildSection(
              '5. Who Can Access Your Data',
              'Access to your submitted data is restricted to the NIA - PIMO Admin Unit only. No other unit or individual has access unless formally authorized by company policy.',
            ),

            _buildSection(
              '6. Data Retention',
              'Your data will be retained for as long as required by company operations and applicable regulations. For questions about retention periods, contact NIA - PIMO Admin Unit.',
            ),

            _buildSection(
              '7. Session & Authentication',
              'For security purposes, this app will require you to re-authenticate every time your mobile device is restarted. Ensure your credentials are kept private and never shared with anyone, including colleagues.',
            ),

            _buildSection(
              '8. Your Responsibilities',
              'By using this app, you agree to:\n\n'
                  '• Use the app only while on duty or for authorized tasks\n'
                  '• Not share your login credentials with any other person\n'
                  '• Not attempt to access, alter, or extract data beyond your permitted scope\n'
                  '• Report any suspicious activity or security concerns to NIA - PIMO Admin Unit immediately',
            ),

            _buildSection(
              '9. Consequences of Misuse',
              'Unauthorized use, sharing of credentials, or any attempt to tamper with app data may result in disciplinary action up to and including termination, in accordance with company policy.',
            ),

            _buildSection(
              '10. Acknowledgment',
              'By tapping "I Agree" below, you confirm that:\n\n'
                  '• You have read and understood these Terms and this Privacy Notice\n'
                  '• You consent to the collection of your location, timestamp, and image data when using the app\n'
                  '• You acknowledge that this app is monitored and administered by the Admin Unit\n\n'
                  'For privacy concerns or data inquiries, \ncontact: NIA - PIMO Admin Unit',
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('I Agree', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
