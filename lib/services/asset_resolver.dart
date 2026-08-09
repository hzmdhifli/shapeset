import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssetResolver {
  /// If set to true, the application will load images and GIFs from the cloud.
  /// If set to false, it will fall back to local assets.
  static bool useCloudStorage = true;

  /// Supabase Configuration
  static String supabaseBaseUrl = 'https://zcbujmjqfozuujioxrio.supabase.co';
  static String supabaseUrl = 'https://zcbujmjqfozuujioxrio.supabase.co/storage/v1/object/public';
  static String supabaseAuthUrl = 'https://zcbujmjqfozuujioxrio.supabase.co/storage/v1/object/authenticated';
  static String defaultSupabaseBucket = 'exercises';
  static String supabaseAnonKey = 'sb_publishable_p4PBU3piZ1SHgV6CfPAZGA_sinYhpUn';

  /// Standard HTTP headers required to read private Supabase buckets
  static Map<String, String> get supabaseHeaders => {
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
  };

  /// Resolves a direct Supabase Storage public or authenticated URL.
  static String getSupabaseUrl(String path, {String bucket = 'female-special-program'}) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$supabaseAuthUrl/$bucket/$cleanPath';
  }

  /// Creates a signed URL for private bucket access via Supabase SDK (valid for 30 days)
  static Future<String?> createSignedUrl(String bucket, String path, {int expiresInSeconds = 60 * 60 * 24 * 30}) async {
    try {
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      return await Supabase.instance.client.storage.from(bucket).createSignedUrl(cleanPath, expiresInSeconds);
    } catch (e) {
      debugPrint('Error creating signed URL for $bucket/$path: $e');
      return null;
    }
  }

  /// The base URL for exercise GIFs in Firebase Storage (fallback).
  static String gifBaseUrl = 'https://firebasestorage.googleapis.com/v0/b/shapeset-e5859.firebasestorage.app/o/';

  /// The base URL for exercise thumbnail static pictures in Firebase Storage (fallback).
  static String picBaseUrl = 'https://firebasestorage.googleapis.com/v0/b/shapeset-e5859.firebasestorage.app/o/';

  /// Generates ordered candidate Supabase Storage URLs (both authenticated & public) for private or public buckets.
  static List<String> getSupabaseVideoCandidates(String filename, {String? originalUrl}) {
    final cleanName = filename.split('/').last;
    final baseName = cleanName
        .replaceAll(RegExp(r'(_pic)?\.(gif|mp4|webm|jpg|jpeg|png|webp)$', caseSensitive: false), '');
    
    final candidates = <String>[
      // Exact filename candidate
      '$supabaseAuthUrl/exercises/$cleanName',
      '$supabaseAuthUrl/female-special-program/$cleanName',
      '$supabaseAuthUrl/legend-athletes/$cleanName',
      
      // Video (.mp4) candidates
      '$supabaseAuthUrl/exercises/$baseName.mp4',
      '$supabaseAuthUrl/exercises/videos/$baseName.mp4',
      '$supabaseAuthUrl/female-special-program/$baseName.mp4',
      '$supabaseAuthUrl/legend-athletes/$baseName.mp4',

      // GIF (.gif) candidates
      '$supabaseAuthUrl/exercises/$baseName.gif',
      '$supabaseAuthUrl/female-special-program/$baseName.gif',
      '$supabaseAuthUrl/legend-athletes/$baseName.gif',
      
      // Public fallbacks
      '$supabaseUrl/exercises/$cleanName',
      '$supabaseUrl/exercises/$baseName.mp4',
      '$supabaseUrl/exercises/$baseName.gif',
      '$supabaseUrl/female-special-program/$cleanName',
      '$supabaseUrl/legend-athletes/$cleanName',
    ];

    if (originalUrl != null && originalUrl.isNotEmpty && !candidates.contains(originalUrl)) {
      candidates.add(originalUrl);
    }
    
    final burnfitFallback = 'https://burnfit.io/wp-content/uploads/$baseName.gif';
    if (!candidates.contains(burnfitFallback)) {
      candidates.add(burnfitFallback);
    }
    
    final burnfitDash1 = 'https://burnfit.io/wp-content/uploads/$baseName-1.gif';
    if (!candidates.contains(burnfitDash1)) {
      candidates.add(burnfitDash1);
    }

    // Related movement fallbacks to prevent 404 errors for curl or raise variations
    if (baseName.contains('CURL') || baseName.contains('BICEP')) {
      candidates.addAll([
        'https://burnfit.io/wp-content/uploads/DB_BC_CURL.gif',
        'https://burnfit.io/wp-content/uploads/EZB_CURL.gif',
        'https://burnfit.io/wp-content/uploads/BB_PREA_CURL.gif',
      ]);
    } else if (baseName.contains('RAISE') || baseName.contains('FRONT')) {
      candidates.addAll([
        'https://burnfit.io/wp-content/uploads/DB_LAT_RAISE-1.gif',
        'https://burnfit.io/wp-content/uploads/DB_BO_LAT_RAISE.gif',
        'https://burnfit.io/wp-content/uploads/BB_PRESS.gif',
      ]);
    }

    return candidates;
  }

  /// Generates ordered candidate Supabase Storage URLs for a GIF file.
  static List<String> getSupabaseGifCandidates(String filename, {String? originalUrl}) {
    return getSupabaseVideoCandidates(filename, originalUrl: originalUrl);
  }

  /// Generates ordered candidate Supabase Storage URLs for a static picture/thumbnail.
  static List<String> getSupabasePicCandidates(String filename) {
    final cleanName = filename.split('/').last;
    final baseName = cleanName
        .replaceAll(RegExp(r'(_pic)?\.(gif|mp4|webm|jpg|jpeg|png|webp)$', caseSensitive: false), '');
        
    return [
      // Pic specific candidates (_pic.jpg, _pic.png, _pic.webp)
      '$supabaseAuthUrl/exercises/${baseName}_pic.jpg',
      '$supabaseAuthUrl/exercises/${baseName}_pic.png',
      '$supabaseAuthUrl/exercises/${baseName}_pic.webp',
      '$supabaseAuthUrl/female-special-program/${baseName}_pic.jpg',
      '$supabaseAuthUrl/female-special-program/${baseName}_pic.png',

      // Standard image candidates (.jpg, .png, .webp)
      '$supabaseAuthUrl/exercises/$baseName.jpg',
      '$supabaseAuthUrl/exercises/$baseName.png',
      '$supabaseAuthUrl/exercises/$baseName.webp',
      '$supabaseAuthUrl/female-special-program/$baseName.jpg',
      '$supabaseAuthUrl/female-special-program/$baseName.png',

      // Exact filename candidate
      '$supabaseAuthUrl/exercises/$cleanName',
      '$supabaseAuthUrl/female-special-program/$cleanName',

      // Public fallbacks
      '$supabaseUrl/exercises/${baseName}_pic.jpg',
      '$supabaseUrl/exercises/$baseName.jpg',
      '$supabaseUrl/female-special-program/$baseName.jpg',
      '$supabaseUrl/exercises/$cleanName',
    ];
  }

  /// Resolves the primary URL for a video/GIF file in Supabase.
  static String getGifUrl(String filename, {bool isFemaleProgram = false}) {
    final cleanName = filename.split('/').last;
    return '$supabaseAuthUrl/exercises/$cleanName';
  }

  /// Resolves the primary URL for a static picture/thumbnail file.
  static String getPicUrl(String filename, {bool isFemaleProgram = false}) {
    final cleanName = filename.split('/').last;
    return '$supabaseAuthUrl/exercises/$cleanName';
  }

  /// Resolves the local asset path.
  static String getLocalPath(String filename) {
    final cleanName = filename.split('/').last;
    return 'assets/images/$cleanName';
  }
}

