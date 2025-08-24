import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ExtensionDownloader extends StatefulWidget {
  const ExtensionDownloader({super.key});

  @override
  State<ExtensionDownloader> createState() => _ExtensionDownloaderState();
}

class _ExtensionDownloaderState extends State<ExtensionDownloader> {
  final TextEditingController _urlController = TextEditingController();
  String _status = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String? extractExtensionId(String url) {
    final RegExp regExp = RegExp(r'itemName=([^&]+)');
    final match = regExp.firstMatch(url);

    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  String generateDownloadUrl(String extensionId) {
    final parts = extensionId.split('.');
    if (parts.length != 2) {
      throw Exception(
        'Invalid extension ID format. Expected format: publisher.name',
      );
    }

    final publisher = parts[0];
    final name = parts[1];

    return 'https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$name/latest/vspackage';
  }

  Future<void> downloadVsixPackage(String url) async {
    setState(() {
      _isLoading = true;
      _status = 'Processing...';
    });

    try {
      final extensionId = extractExtensionId(url);

      if (extensionId == null) {
        throw Exception('Could not extract extension ID from URL');
      }

      final downloadUrl = generateDownloadUrl(extensionId);

      await downloadAndSaveVsix(extensionId, downloadUrl);

      setState(() {
        _status = 'Extension download initiated successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> downloadAndSaveVsix(
    String extensionId,
    String downloadUrl,
  ) async {
    try {
      final customFileName = extensionId;

      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = downloadUrl
        ..style.display = 'none';

      web.document.body!.appendChild(anchor);
      anchor.click();

      anchor.remove();

      setState(() {
        _status = 'Downloading: $customFileName';
      });

      return;
    } catch (e) {
      throw Exception('Failed to download VSIX: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.extension,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'VS Code Extension Downloader',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Download VSIX packages directly from the VS Code Marketplace with a single click',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Enter Extension URL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Paste a URL from the VS Code Marketplace',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: TextField(
                            controller: _urlController,
                            decoration: InputDecoration(
                              labelText: 'Extension URL',
                              prefixIcon: const Icon(Icons.link),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.url,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () =>
                                      downloadVsixPackage(_urlController.text),
                            icon: _isLoading
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2.0),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.file_download),
                            label: Text(
                              _isLoading
                                  ? 'Processing...'
                                  : 'Download Extension',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_status.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: _status.startsWith('Error')
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _status.startsWith('Error')
                            ? Colors.red.shade200
                            : Colors.green.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _status.startsWith('Error')
                              ? Colors.red.withAlpha(230)
                              : Colors.green.withAlpha(230),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          _status.startsWith('Error')
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          color: _status.startsWith('Error')
                              ? Colors.red
                              : Colors.green,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _status,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: _status.startsWith('Error')
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Text('Made with ❤️ using Flutter'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
