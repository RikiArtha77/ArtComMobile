import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          'http://192.168.1.14:8000/api/google-auth-setup/${widget.userId}',
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
        Uri.parse('http://192.168.1.14:8000/api/verify-totp'),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Aktifkan Google Authenticator",
          style: TextStyle(color: Color(0xFF757575)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF757575)),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Google Authenticator",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Scan QR Code di aplikasi Google Authenticator,\nlalu masukkan 6-digit kode di bawah.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  const SizedBox(height: 24),
                  _qrUrl != null
                      ? QrImageView(
                          data: _qrUrl!,
                          version: QrVersions.auto,
                          size: 200.0,
                        )
                      : const CircularProgressIndicator(),

                  const SizedBox(height: 24),
                  TextField(
                    controller: _otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      hintText: '000000',
                      labelText: 'Kode OTP',
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyTotp,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF7643),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Verifikasi"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
