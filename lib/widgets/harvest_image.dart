import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../app_config/theme.dart';

class HarvestImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;

  // In-memory cache for decoded base64 bytes to eliminate re-decoding and prevent blinking
  static final Map<String, Uint8List> _bytesCache = {};

  const HarvestImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.eco_rounded,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    final trimmed = imageUrl.trim();

    if (trimmed.isEmpty) {
      content = _fallback();
    } else if (trimmed.startsWith('data:image')) {
      try {
        final cacheKey = '${trimmed.length}_${trimmed.substring(0, trimmed.length.clamp(0, 60))}';
        Uint8List? bytes = _bytesCache[cacheKey];
        if (bytes == null) {
          final commaIdx = trimmed.indexOf(',');
          final base64Str = commaIdx != -1 ? trimmed.substring(commaIdx + 1) : trimmed;
          bytes = base64Decode(base64Str);
          if (_bytesCache.length > 80) _bytesCache.clear();
          _bytesCache[cacheKey] = bytes;
        }
        content = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true, // Prevents image from disappearing during rebuilds
          errorBuilder: (_, _, _) => _fallback(),
        );
      } catch (_) {
        content = _fallback();
      }
    } else if (trimmed.startsWith('file://') || (trimmed.startsWith('/') && !trimmed.startsWith('//')) || (trimmed.length > 2 && trimmed[1] == ':')) {
      final path = trimmed.startsWith('file://') ? trimmed.replaceFirst('file://', '') : trimmed;
      content = Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _fallback(),
      );
    } else {
      content = Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.primarySurface,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.primarySurface,
      child: Center(
        child: Icon(fallbackIcon, size: (width != null && width! < 60) ? 22 : 36, color: AppColors.primary),
      ),
    );
  }
}
