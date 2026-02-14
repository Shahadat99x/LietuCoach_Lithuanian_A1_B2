import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLinksService {
  static const String privacyPolicyUrl =
      'https://lietucoach.vercel.app/privacy';
  static const String termsUrl = 'https://lietucoach.vercel.app/terms';
  static const String dataDeletionUrl =
      'https://lietucoach.vercel.app/data-deletion';
  static const String supportUrl = 'https://lietucoach.vercel.app/support';
  static const String supportEmail = 'hello@dhossain.com';

  static Future<void> openUrl(BuildContext context, String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      debugPrint('ExternalLinksService: Attempting to launch $uri');

      final canLaunch = await canLaunchUrl(uri);
      debugPrint(
        'ExternalLinksService: canLaunchUrl($uri) returned $canLaunch',
      );

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('ExternalLinksService: Could not launch $uri');
        if (context.mounted) {
          _showError(context, 'Could not open link.');
        }
      }
    } catch (e) {
      debugPrint('ExternalLinksService: Exception launching $urlString: $e');
      if (context.mounted) {
        _showError(context, 'Couldn\'t open link. Please try again.');
      }
    }
  }

  static Future<void> openEmail(BuildContext context) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: supportEmail,
        query: 'subject=LietuCoach Support', // Basic subject line
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open email app.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Could not open email app: $e');
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
