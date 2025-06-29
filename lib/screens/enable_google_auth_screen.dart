import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnableGoogleAuthScreen extends StatefulWidget {
  final int userId;

  const EnableGoogleAuthScreen({super.key, required this.userId});

  @override
  State<EnableGoogleAuthScreen> createState() => _EnableGoogleAuthScreenState();
}

class _EnableGoogleAuthScreenState extends State<EnableGoogleAuthScreen> {
  String? _qrUrl;
  final _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _getQrCode();
  }

  Future<void> _getQrCode() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://192.168.1.9:8000/api/google-auth-setup/${widget.userId}',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _qrUrl = data['qr_url'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat QR Code: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _verifyTotp() async {
    setState(() => _isVerifying = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.9:8000/api/verify-totp'),
        headers: {'Accept': 'application/json'},
        body: {
          'user_id': widget.userId.toString(),
          'code': _otpController.text.trim(),
        },
      );

      setState(() => _isVerifying = false);

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Kode OTP salah')),
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aktifkan Google Authenticator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_qrUrl != null)
              QrImageView(data: _qrUrl!, version: QrVersions.auto, size: 200.0)
            else
              const CircularProgressIndicator(),

            const SizedBox(height: 24),
            const Text(
              'Scan QR Code di aplikasi Google Authenticator, lalu masukkan 6-digit kode di bawah ini.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Kode OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyTotp,
              child: _isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}
