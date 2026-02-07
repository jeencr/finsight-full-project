import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<dynamic> _chatMessages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String _expertName = "Loading...";
  String _expertId = "";
  String _userId = "";
  Timer? _pollingTimer;

  // FINSIGHT Colors
  final Color _primaryColor = const Color(0xFFEB1616);
  final Color _secondaryColor = const Color(0xFF191C24);
  final Color _darkColor = const Color(0xFF000000);
  final Color _lightColor = const Color(0xFF6C7293);
  final Color _myMessageColor = const Color(0xFFEB1616);
  final Color _expertMessageColor = const Color(0xFF191C24);

  @override
  void initState() {
    super.initState();
    _loadChatData();
    _startPolling();

    // Scroll to bottom when keyboard appears
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll for new messages every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isLoading && !_isSending) {
        _loadChatMessages();
      }
    });
  }

  Future<void> _loadChatData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    int? lid = sh.getInt('lid');
    String? url = sh.getString('url');

    if (lid == null || url == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Store user ID
      setState(() {
        _userId = lid.toString();
      });

      // First, get expert information
      final expertResponse = await http.post(
        Uri.parse('$url/get_assigned_expert/'),
        body: {'lid': lid.toString()},
      );

      if (expertResponse.statusCode == 200) {
        final expertData = json.decode(expertResponse.body);
        setState(() {
          _expertName = expertData['expert_name'] ?? 'Investment Expert';
          _expertId = expertData['expert_login_id'] ?? '';
        });

        // Then load chat messages
        await _loadChatMessages();
      } else {
        setState(() {
          _expertName = 'Investment Expert';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading chat data: $e');
      setState(() {
        _isLoading = false;
        _expertName = 'Investment Expert';
      });
    }
  }

  Future<void> _loadChatMessages() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    int? lid = sh.getInt('lid');
    String? url = sh.getString('url');

    if (lid == null || url == null) return;

    try {
      final response = await http.post(
        Uri.parse('$url/view_chat_user/'),
        body: {'lid': lid.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _chatMessages = data['chat'] ?? [];
          _isLoading = false;
          _expertName = data['expert_name'] ?? 'Investment Expert';
          print(_expertName+'widfjiowejfie');

        });
        // Scroll to bottom after loading messages
        _scrollToBottom();
      }
    } catch (e) {
      print('Error loading chat messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    int? lid = sh.getInt('lid');
    String? url = sh.getString('url');

    if (lid == null || url == null) {
      setState(() {
        _isSending = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/chat_with_expert/'),
        body: {
          'lid': lid.toString(),
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        _messageController.clear();

        // Add message to local list immediately
        setState(() {
          _chatMessages.add({
            'id': DateTime.now().millisecondsSinceEpoch,
            'from_id': lid.toString(),
            'to_id': _expertId,
            'message': message,
            'date': DateTime.now().toIso8601String(),

          });

        });

        // Scroll to bottom and reload messages
        _scrollToBottom();
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadChatMessages();
      }
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool _isMyMessage(Map<String, dynamic> message) {
    // Compare the from_id with current user's ID
    // Both are strings from backend
    print("${message['from_id']}  fgygy ${_userId} sbdjudhuidjiuwd" );
    return message['from_id'] == _userId;
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMyMessage = _isMyMessage(message);
    final dateTime = DateTime.parse(message['date']);
    final formattedTime = DateFormat('h:mm a').format(dateTime);
    final formattedDate = DateFormat('MMM d, yyyy').format(dateTime);

    return Container(
      margin: EdgeInsets.only(
        left: isMyMessage ? 40 : 8,
        right: isMyMessage ? 8 : 40,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Date separator if new day
          if (_shouldShowDateSeparator(message))
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formattedDate,
                style: TextStyle(
                  color: _lightColor,
                  fontSize: 11,
                ),
              ),
            ),

          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Column(
              crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMyMessage ? _myMessageColor : _expertMessageColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMyMessage ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMyMessage ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message['message'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // Time and status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: _lightColor,
                        fontSize: 10,
                      ),
                    ),
                    if (isMyMessage) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message['status'] == 'sent' ? Icons.done : Icons.done_all,
                        color: message['status'] == 'read' ? Colors.blue : _lightColor,
                        size: 12,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateSeparator(Map<String, dynamic> message) {
    final currentDate = DateTime.parse(message['date']);
    final messageIndex = _chatMessages.indexOf(message);

    if (messageIndex == 0) return true;

    final previousDate = DateTime.parse(_chatMessages[messageIndex - 1]['date']);
    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _secondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline, color: _lightColor, size: 64),
          const SizedBox(height: 24),
          const Text(
            'Start a Conversation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Send your first message to $_expertName for personalized investment advice.',
            style: TextStyle(
              color: _lightColor,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkColor,
      appBar: AppBar(
        backgroundColor: _secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: _primaryColor, width: 1),
              ),
              child: Icon(Icons.person, color: _primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _expertName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Investment Expert',
                  style: TextStyle(
                    color: _lightColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Show more options
              print('More options');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondaryColor,
              border: Border(
                bottom: BorderSide(color: _lightColor.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: _primaryColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Get personalized investment advice from your expert',
                    style: TextStyle(
                      color: _lightColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Live',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: Container(
              color: _darkColor,
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFEB1616)),
              )
                  : _chatMessages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _chatMessages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _chatMessages.length) {
                    return const SizedBox(height: 80);
                  }

                  final message = _chatMessages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _secondaryColor,
              border: Border(
                top: BorderSide(color: _lightColor.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _darkColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: _lightColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(color: _lightColor, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            maxLines: 5,
                            minLines: 1,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.attach_file, color: _lightColor, size: 20),
                          onPressed: () {
                            // TODO: Attach file
                            print('Attach file');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}