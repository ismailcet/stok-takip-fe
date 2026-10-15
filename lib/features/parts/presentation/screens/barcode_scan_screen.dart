import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/scan/scan_bloc.dart';
import '../../bloc/scan/scan_event.dart';
import '../../bloc/scan/scan_state.dart';
import '../../data/repositories/part_repository.dart';
import 'part_detail_screen.dart';

class BarcodeScanScreen extends StatelessWidget {
  const BarcodeScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanBloc(partRepository: PartRepository()),
      child: const _ScanView(),
    );
  }
}

class _ScanView extends StatefulWidget {
  const _ScanView();

  @override
  State<_ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<_ScanView> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BuildContext context, BarcodeCapture capture) {
    final code =
        capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    context.read<ScanBloc>().add(ScanCodeDetected(code));
  }

  Future<void> _askProductCode(BuildContext context) async {
    final bloc = context.read<ScanBloc>();
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ProductCodeDialog(),
    );
    if (code != null && code.isNotEmpty) {
      await _controller.stop();
      bloc.add(ScanProductCodeSubmitted(code));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanBloc, ScanState>(
      listener: (context, state) {
        if (state.status == ScanStatus.lookingUp) {
          _controller.stop();
        } else if (state.status == ScanStatus.scanning) {
          _controller.start();
        } else if (state.status == ScanStatus.found) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => PartDetailScreen(part: state.part!),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scannerBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Builder(
              builder:
                  (context) => MobileScanner(
                    controller: _controller,
                    onDetect: (capture) => _onDetect(context, capture),
                    errorBuilder:
                        (context, error) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'Kamera açılamadı.\nÜrün kodunu elle yazabilirsin.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                  ),
            ),
            // Tarama çerçevesi
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.accentLight, width: 4),
                ),
              ),
            ),
            // Alt kısım
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Barkodu çerçevenin içine al',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder:
                            (context) => OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white54,
                                  width: 2,
                                ),
                              ),
                              onPressed: () => _askProductCode(context),
                              child: const Text('Ürün Kodunu Yaz'),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Arama / bulunamadı katmanı
            BlocBuilder<ScanBloc, ScanState>(
              builder: (context, state) {
                if (state.status == ScanStatus.lookingUp) {
                  return Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentLight,
                      ),
                    ),
                  );
                }
                if (state.status == ScanStatus.notFound) {
                  return Container(
                    color: Colors.black87,
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.danger,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message ?? 'Parça bulunamadı',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 28),
                          ElevatedButton(
                            onPressed:
                                () => context.read<ScanBloc>().add(
                                  const ScanRetried(),
                                ),
                            child: const Text('Tekrar Dene'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Colors.white54,
                                width: 2,
                              ),
                            ),
                            onPressed: () => _askProductCode(context),
                            child: const Text('Ürün Kodunu Yaz'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Üst çubuk (en üstte: katmanın üstünde kalır, X her zaman çalışır)
            Align(
              alignment: Alignment.topLeft,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Barkod Tara',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCodeDialog extends StatefulWidget {
  const _ProductCodeDialog();

  @override
  State<_ProductCodeDialog> createState() => _ProductCodeDialogState();
}

class _ProductCodeDialogState extends State<_ProductCodeDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_textController.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: const Text('Ürün Kodunu Yaz'),
      content: TextField(
        controller: _textController,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(hintText: 'Ürün kodu'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        TextButton(onPressed: _submit, child: const Text('Ara')),
      ],
    );
  }
}
