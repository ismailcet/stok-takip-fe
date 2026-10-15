import 'package:flutter/material.dart';
import '../storage/secure_storage_service.dart';
import '../theme/app_theme.dart';

/// Token gerektiren bir adresten görsel yükler.
class AuthNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;

  const AuthNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
  });

  @override
  State<AuthNetworkImage> createState() => _AuthNetworkImageState();
}

class _AuthNetworkImageState extends State<AuthNetworkImage> {
  late final Future<String?> _token = SecureStorageService.instance.readToken();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _token,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final token = snapshot.data;
        return Image.network(
          widget.url,
          fit: widget.fit,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder:
              (context, error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Fotoğraf yüklenemedi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }
}
