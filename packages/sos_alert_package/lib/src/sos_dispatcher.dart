import 'package:url_launcher/url_launcher.dart';
import 'emergency_contact.dart';
import 'location_service.dart';

/// Result of attempting to dispatch an SOS alert.
class SosDispatchResult {
  final bool success;
  final String message;
  const SosDispatchResult({required this.success, required this.message});
}

/// Core "send the alert" logic for the SOS app.
///
/// Builds a message containing the user's live location and opens
/// the device's SMS composer (pre-filled) for each emergency contact.
/// It can also place an emergency call to a single number (e.g. 112/911
/// or the top-priority contact).
class SosDispatcher {
  final LocationService _locationService;

  SosDispatcher({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  /// Builds the SOS text message, including a Google Maps link if
  /// location could be resolved.
  Future<String> buildMessage({String? customNote}) async {
    final position = await _locationService.getCurrentLocation();
    final buffer = StringBuffer();
    buffer.write('🚨 EMERGENCY SOS ALERT 🚨\n');
    buffer.write('I need help. Please contact me or come immediately.\n');
    if (customNote != null && customNote.trim().isNotEmpty) {
      buffer.write('Note: $customNote\n');
    }
    if (position != null) {
      buffer.write('My current location: ${_locationService.mapsLinkFor(position)}\n');
    } else {
      buffer.write('Location unavailable at this moment.\n');
    }
    return buffer.toString();
  }

  /// Opens the SMS app pre-filled with the SOS message for a single
  /// contact. Returns whether the SMS composer could be launched.
  Future<SosDispatchResult> sendSmsTo(
    EmergencyContact contact, {
    String? message,
  }) async {
    final body = message ?? await buildMessage();
    final uri = Uri(
      scheme: 'sms',
      path: contact.phoneNumber,
      queryParameters: {'body': body},
    );

    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(uri);
      return SosDispatchResult(
        success: launched,
        message: launched
            ? 'SMS composer opened for ${contact.name}.'
            : 'Failed to open SMS composer for ${contact.name}.',
      );
    }
    return SosDispatchResult(
      success: false,
      message: 'Cannot launch SMS on this device for ${contact.name}.',
    );
  }

  /// Sends the SOS alert to every contact in [contacts] sequentially.
  Future<List<SosDispatchResult>> sendToAll(
    List<EmergencyContact> contacts,
  ) async {
    final message = await buildMessage();
    final results = <SosDispatchResult>[];
    for (final contact in contacts) {
      results.add(await sendSmsTo(contact, message: message));
    }
    return results;
  }

  /// Places a direct phone call to [phoneNumber] (e.g. an emergency
  /// services number like 112 or 911, or a priority contact).
  Future<SosDispatchResult> callNumber(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(uri);
      return SosDispatchResult(
        success: launched,
        message: launched ? 'Calling $phoneNumber...' : 'Failed to place call.',
      );
    }
    return SosDispatchResult(
      success: false,
      message: 'Cannot place calls on this device.',
    );
  }
}
