import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_app_bar.dart';
import '../controllers/messages_controller.dart';
import 'package:intl/intl.dart';

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  final MessagesController controller = Get.find<MessagesController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool isNearBottom = true;
  int _lastMessagesCount = 0;

  @override
  void initState() {
    super.initState();

    // Add scroll listener to detect when user scrolls
    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEmployees();
      controller.startPeriodicFetch();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    controller.stopPeriodicFetch();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;
      // Consider "near bottom" if within 100 pixels of the bottom
      setState(() {
        isNearBottom = maxScroll - currentScroll <= 100;
      });
    }
  }

  void _scrollToBottom() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Messages',
        showLogoutButton: true,
      ),
      body: Obx(() {
        if (controller.employees.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Only scroll if a new message is added and user is near bottom
        if (controller.messages.length > _lastMessagesCount && isNearBottom) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }
        _lastMessagesCount = controller.messages.length;

        return Row(
          children: [
            // Left side - Employee List
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Liste des Employés',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.employees.length,
                      itemBuilder: (context, index) {
                        final employee = controller.employees[index];
                        final isSelected = employee['id'] ==
                            controller.selectedEmployeeId.value;
                        return _buildEmployeeListItem(
                          employee['full_name'],
                          isSelected,
                          () {
                            controller.fetchMessages(employee['id']);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Right side - Chat Area
            Expanded(
              child: Column(
                children: [
                  // Welcome Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          'Bienvenue Admin',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.getSelectedEmployeeName(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chat Messages
                  Expanded(
                    child: Obx(() {
                      return controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : controller.messages.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Aucun message',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.all(16),
                                  reverse: true,
                                  itemCount: controller.messages.length,
                                  itemBuilder: (context, index) {
                                    final messageIndex =
                                        controller.messages.length - 1 - index;
                                    final message =
                                        controller.messages[messageIndex];
                                    final isAdmin =
                                        message['from_admin'] ?? false;
                                    final time =
                                        DateTime.parse(message['created_at']);

                                    return _buildMessage(
                                      sender: isAdmin
                                          ? 'Me'
                                          : controller
                                              .getSelectedEmployeeName(),
                                      message: message['content'],
                                      time: DateFormat('d MMM yyyy hh:mm a')
                                          .format(time),
                                      isAdmin: isAdmin,
                                    );
                                  },
                                );
                    }),
                  ),
                  // Message Input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.note_alt_outlined,
                                  color: Colors.grey),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Tapez votre message ici...',
                                    border: InputBorder.none,
                                  ),
                                  maxLines: null,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) {
                                    if (controller
                                        .selectedEmployeeId.isNotEmpty) {
                                      _sendMessage();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: Obx(() => InkWell(
                                onTap: controller.selectedEmployeeId.isEmpty
                                    ? null
                                    : _sendMessage,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: controller.selectedEmployeeId.isEmpty
                                        ? Colors.grey.withOpacity(0.3)
                                        : Colors.purple,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Envoyer',
                                        style: TextStyle(
                                          color: controller
                                                  .selectedEmployeeId.isEmpty
                                              ? Colors.grey.shade700
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.send,
                                        size: 16,
                                        color: controller
                                                .selectedEmployeeId.isEmpty
                                            ? Colors.grey.shade700
                                            : Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty ||
        controller.selectedEmployeeId.isEmpty) {
      return;
    }

    controller.sendMessage(
      messageController.text,
      controller.selectedEmployeeId.value,
    );
    messageController.clear();
    FocusScope.of(context).requestFocus(FocusNode());

    // Always scroll to bottom after sending a message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Widget _buildEmployeeListItem(
      String name, bool isSelected, VoidCallback onTap) {
    return Container(
      color: isSelected ? Colors.purple.withOpacity(0.1) : null,
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.purple : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMessage({
    required String sender,
    required String message,
    required String time,
    required bool isAdmin,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment:
                isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (!isAdmin) ...[
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                sender,
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.5,
            ),
            decoration: BoxDecoration(
              color: isAdmin
                  ? Colors.purple.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAdmin
                    ? Colors.purple.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isAdmin ? Colors.purple.shade700 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
