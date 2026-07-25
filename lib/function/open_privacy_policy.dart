import 'package:app_ramos_candidatura/app_config/const/app_api_config.dart';
import 'package:app_ramos_candidatura/function/show_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openPrivacyPolicy() async {
  final uri = Uri.parse(AppApiConfig.privacyPolicyUrl);
  final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  if (opened) return;

  final fallback = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!fallback) {
    showToastError(message: 'Não foi possível abrir a política de privacidade');
  }
}
