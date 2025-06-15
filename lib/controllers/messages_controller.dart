import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/login_controller.dart';
import 'dart:async';

class MessagesController extends GetxController {
  final _supabase = Supabase.instance.client;
  final LoginController _loginController = Get.find<LoginController>();
  Timer? _refreshTimer;

  final employees = <Map<String, dynamic>>[].obs;
  final messages = <Map<String, dynamic>>[].obs;
  final selectedEmployeeId = RxString('');
  final isLoading = false.obs;
  int? _lastMessageId;
  final messagesVersion = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('MessagesController initialized');
  }

  void startPeriodicFetch() {
    debugPrint('Starting periodic fetch');
    stopPeriodicFetch();

    // Fetch immediately when starting
    if (selectedEmployeeId.isNotEmpty) {
      fetchMessages(selectedEmployeeId.value);
    }

    // Start new timer that checks for new messages every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkForNewMessages();
    });
  }

  Future<void> checkForNewMessages() async {
    if (selectedEmployeeId.isEmpty) return;

    try {
      // Query for messages with ID greater than our last known message ID
      var query = _supabase.from('messages').select().or(
          'mobile_id.eq.${selectedEmployeeId.value},admin_id.eq.${selectedEmployeeId.value}');

      // If we have a last message ID, only check for newer ones
      if (_lastMessageId != null) {
        query = query.gt('id', _lastMessageId!);
      }

      final newMessages = await query;

      // If we found new messages, update our list
      if ((newMessages as List).isNotEmpty) {
        final typedMessages = List<Map<String, dynamic>>.from(newMessages);

        // If this is our first fetch, just set the messages
        if (_lastMessageId == null) {
          messages.value = typedMessages;
        } else {
          // Otherwise, add only the new messages
          messages.addAll(typedMessages);
        }

        // Update the last message ID
        if (typedMessages.isNotEmpty) {
          _lastMessageId = typedMessages.last['id'];
          messagesVersion.value++; // Trigger UI update
        }
      }
    } catch (e) {
      debugPrint('Error checking for new messages: $e');
    }
  }

  void stopPeriodicFetch() {
    debugPrint('Stopping periodic fetch');
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> fetchEmployees() async {
    debugPrint('Fetching employees...');
    try {
      isLoading.value = true;
      final response = await _supabase
          .from('users')
          .select('id, full_name')
          .eq('is_admin', false)
          .order('full_name');

      debugPrint('Fetched employees: $response');
      employees.value = List<Map<String, dynamic>>.from(response);

      if (employees.isNotEmpty && selectedEmployeeId.isEmpty) {
        debugPrint('Setting initial employee: ${employees[0]}');
        selectedEmployeeId.value = employees[0]['id'];
        await fetchMessages(selectedEmployeeId.value);
      }
    } catch (e) {
      debugPrint('Error fetching employees: $e');
      Get.snackbar(
        'Erreur',
        'Échec du chargement des employés: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMessages(String employeeId) async {
    if (employeeId.isEmpty) return;

    debugPrint('Fetching messages for employee: $employeeId');
    try {
      isLoading.value = true;
      selectedEmployeeId.value = employeeId;

      final response = await _supabase
          .from('messages')
          .select()
          .or('mobile_id.eq.$employeeId,admin_id.eq.$employeeId')
          .order('created_at', ascending: true);

      debugPrint('Fetched messages: $response');
      messages.value = List<Map<String, dynamic>>.from(response);

      // Update the last message ID
      if (messages.isNotEmpty) {
        _lastMessageId = messages.last['id'];
      }

      debugPrint('Messages count: ${messages.length}');
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      Get.snackbar(
        'Erreur',
        'Échec du chargement des messages: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      messages.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String content, String employeeId) async {
    if (content.trim().isEmpty || employeeId.isEmpty) return;

    try {
      final adminId = _loginController.currentAdminId.value;
      if (adminId.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Informations administrateur non trouvées. Veuillez vous reconnecter.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      final response = await _supabase
          .from('messages')
          .insert({
            'content': content,
            'mobile_id': employeeId,
            'admin_id': adminId,
            'created_at': DateTime.now().toIso8601String(),
            'from_admin': true,
          })
          .select()
          .single();

      // Add the new message to our list
      messages.add(response);
      _lastMessageId = response['id'];
      messagesVersion.value++; // Trigger UI update

      Get.snackbar(
        'Succès',
        'Message envoyé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      Get.snackbar(
        'Erreur',
        'Échec de l\'envoi du message: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  String getSelectedEmployeeName() {
    if (selectedEmployeeId.isEmpty) return '';

    final selectedEmployee = employees
        .firstWhereOrNull((emp) => emp['id'] == selectedEmployeeId.value);
    return selectedEmployee?['full_name'] ?? '';
  }

  @override
  void onClose() {
    stopPeriodicFetch();
    super.onClose();
  }

  int? get lastMessageId => _lastMessageId;
}
