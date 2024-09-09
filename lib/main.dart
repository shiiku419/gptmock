import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'api_key.dart';

const backgroundColor = Color(0xFF343541);
const sidebarColor = Color(0xFF444654);
const textColor = TextStyle(color: Colors.white);
const kSemiBold = FontWeight.w600;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Mock',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: sidebarColor,
          elevation: 1,
          shadowColor: Colors.white12,
        ),
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white),
      ),
      home: ChatScreen(),
    );
  }
}

class Conversation {
  final String id;
  String title;
  final List<ChatMessage> messages;

  Conversation({required this.id, required this.title, required this.messages});
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Conversation> _conversations = [];
  late Conversation _currentConversation;
  final TextEditingController _textController = TextEditingController();
  late OpenAI openAI;
  bool _isLoading = false;
  String _selectedModelString = 'gpt-3.5-turbo';
  late ScrollController _scrollController;
  bool _isSidebarCollapsed = false;

  final List<String> _availableModels = [
    'gpt-3.5-turbo',
    'gpt-4',
  ];

  ChatModel _getChatModelFromString(String modelString) {
    switch (modelString) {
      case 'gpt-3.5-turbo':
        return GptTurboChatModel();
      case 'gpt-4':
        return Gpt4ChatModel();
      default:
        return GptTurboChatModel();
    }
  }

  @override
  void initState() {
    super.initState();
    final token = OPENAI_API_KEY;
    if (token == null) {
      print('Error: OPENAI_API_KEY environment variable not set');
      return;
    }
    openAI = OpenAI.instance.build(
      token: token,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
    );
    _scrollController = ScrollController();
    _createNewConversation();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _createNewConversation() {
    final newConversation = Conversation(
      id: Uuid().v4(),
      title: 'New Chat',
      messages: [],
    );
    setState(() {
      _conversations.add(newConversation);
      _currentConversation = newConversation;
    });
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    ChatMessage userMessage = ChatMessage(
      text: text,
      isUser: true,
    );
    setState(() {
      _currentConversation.messages.add(userMessage);
      _isLoading = true;
    });
    
    String response = await _getBotResponse(text);
    
    ChatMessage botMessage = ChatMessage(
      text: response,
      isUser: false,
    );
    setState(() {
      _currentConversation.messages.add(botMessage);
      _isLoading = false;
      if (_currentConversation.messages.length == 2) {
        _currentConversation.title = text.length > 30 ? text.substring(0, 30) + '...' : text;
      }
    });
    _scrollToBottom();
  }

  Future<String> _getBotResponse(String userMessage) async {
    try {
      final request = ChatCompleteText(
        messages: [
          Messages(role: Role.user, content: userMessage),
        ],
        maxToken: 500,
        model: _getChatModelFromString(_selectedModelString),
      );

      final response = await openAI.onChatCompletion(request: request);
      return response?.choices.last.message?.content ?? 'エラーが発生しました。もう一度お試しください。';
    } catch (e) {
      print('Error: $e');
      return 'エラーが発生しました。もう一度お試しください。';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  void _openVoiceChatMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceChatScreen(
          openAI: openAI,
          modelString: _selectedModelString,
        ),
      ),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.white12,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(_isSidebarCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
          onPressed: _toggleSidebar,
        ),
        title: Text(
          "ChatGPT Mock",
          style: textColor.copyWith(fontSize: 20, fontWeight: kSemiBold),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (!_isSidebarCollapsed) _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildChatList(),
                  _buildTextInput(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: sidebarColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _createNewConversation,
              child: Text('New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF10A37F),
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedModelString,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedModelString = newValue;
                  });
                }
              },
              items: _availableModels.map<DropdownMenuItem<String>>((String model) {
                return DropdownMenuItem<String>(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_conversations[index].title),
                  onTap: () {
                    setState(() {
                      _currentConversation = _conversations[index];
                    });
                  },
                  selected: _currentConversation.id == _conversations[index].id,
                  selectedTileColor: backgroundColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Expanded(
      child: ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 16),
        itemCount: _currentConversation.messages.length,
        itemBuilder: (BuildContext context, int index) {
          final message = _currentConversation.messages[index];
          return message.isUser
              ? UserQuestionWidget(question: message.text)
              : ChatGptAnswerWidget(answer: message.text);
        },
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(color: sidebarColor),
      child: TextInputWidget(
        textController: _textController,
        onSubmitted: () => _handleSubmitted(_textController.text),
        onVoiceChatPressed: _openVoiceChatMode,
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class UserQuestionWidget extends StatelessWidget {
  final String question;

  const UserQuestionWidget({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sidebarColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(question, style: textColor),
    );
  }
}

class ChatGptAnswerWidget extends StatelessWidget {
  final String answer;

  const ChatGptAnswerWidget({Key? key, required this.answer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(answer, style: textColor),
    );
  }
}

class TextInputWidget extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSubmitted;
  final VoidCallback onVoiceChatPressed;

  const TextInputWidget({
    Key? key,
    required this.textController,
    required this.onSubmitted,
    required this.onVoiceChatPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: "メッセージを入力",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: backgroundColor,
                filled: true,
              ),
              style: textColor,
              onSubmitted: (_) => onSubmitted(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: onSubmitted,
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.record_voice_over),
            onPressed: onVoiceChatPressed,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class VoiceChatScreen extends StatefulWidget {
  final OpenAI openAI;
  final String modelString;

  const VoiceChatScreen({Key? key, required this.openAI, required this.modelString}) : super(key: key);

  @override
  _VoiceChatScreenState createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _lastWords = '';
  String _aiResponse = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speech.listen(onResult: _onSpeechResult);
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    if (_lastWords.isNotEmpty) {
      _getAiResponse();
    }
  }

  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _getAiResponse() async {
    final request = ChatCompleteText(
      messages: [
        Messages(role: Role.user, content: _lastWords),
      ],
      maxToken: 500,
      model: _getChatModelFromString(widget.modelString),
    );

    final response = await widget.openAI.onChatCompletion(request: request);
    setState(() {
      _aiResponse = response?.choices.last.message?.content ?? 'エラーが発生しました。もう一度お試しください。';
    });
    await _speak(_aiResponse);
  }

  ChatModel _getChatModelFromString(String modelString) {
    switch (modelString) {
      case 'gpt-3.5-turbo':
        return GptTurboChatModel();
      case 'gpt-4':
        return Gpt4ChatModel();
      default:
        return GptTurboChatModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('音声チャット'),
        backgroundColor: Color(0xFF343541),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isListening ? 'お話しください...' : '音声チャットを開始',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              _aiResponse,
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTapDown: (_) => _startListening(),
              onTapUp: (_) => _stopListening(),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Color(0xFF10A37F),
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF343541),
    );
  }
}
