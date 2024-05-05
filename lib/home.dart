import 'package:flutter/material.dart';
import 'message.dart';
import 'package:intl/intl.dart';
import 'l10n/app_en_US.dart' as enUS;
import 'l10n/app_ru_RU.dart' as ruRU;
import 'AI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final fsconnect = FirebaseFirestore.instance;
  List<Message> _messages = <Message>[];
  final AI ai = AI();
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late FocusNode _focusNode;
  Map<String, String> translations = enUS.enUS; // Инициализация на английском
  String currentLanguage = 'English'; // Переменная для хранения текущего языка

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    get_dialogue().then((value) {
      setState(() {
        _messages = value;
        _messages.sort((a, b) => b.date.compareTo(a.date));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(translations['appTitle'] ?? 'Voice Assistant'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.language),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text('Русский'),
                  onTap: () {
                    setState(() {
                      translations = ruRU.ruRU;
                      currentLanguage = 'Русский';
                    });
                  },
                ),
                PopupMenuItem(
                  child: Text('English'),
                  onTap: () {
                    setState(() {
                      translations = enUS.enUS;
                      currentLanguage = 'English';
                    });
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _getItem(_messages[index]),
            ),
          ),
          Container(
            color: Colors.grey[200],
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    onSubmitted: (String value) {
                      _senderMessage(value);
                    },
                    decoration: InputDecoration(hintText: translations['sendHint'] ?? 'Send a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _senderMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getItem(Message message) {
    return Container(
      color: message.isSend ? Colors.tealAccent : Colors.limeAccent,
      margin: message.isSend
          ? const EdgeInsets.fromLTRB(80, 8, 4, 4)
          : const EdgeInsets.fromLTRB(4, 8, 80, 4),
      child: message.isSend
          ? _getMyListTile(message)
          : _getAssistentListTile(message),
    );
  }

  Widget _getMyListTile(Message message) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(Icons.face),
        title: Text(
          message.text,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 18),
        ),
        subtitle: Text(message.date, textAlign: TextAlign.left),
      ),
    );
  }

  Widget _getAssistentListTile(Message message) {
    return ListTile(
      trailing: Icon(Icons.assistant),
      title: Text(
        message.text,
        textAlign: TextAlign.left,
        style: const TextStyle(fontSize: 18),
      ),
      subtitle: Text(message.date, textAlign: TextAlign.left),
    );
  }

  void _senderMessage(String question) async {
    final DateTime questionTime = DateTime.now();
    final String formattedQuestionDate = DateFormat('yyyy-MM-dd – kk:mm:ss.SSS').format(questionTime);
    _textController.clear();

    final String answer = await AI().getAnswer(question);
    final DateTime answerTime = DateTime.now();
    final String formattedAnswerDate = DateFormat('yyyy-MM-dd – kk:mm:ss.SSS').format(answerTime);

    // Дождитесь завершения добавления вопроса
    await Future.delayed(Duration(milliseconds: 200));

    setState(() {
      _messages.insert(0, Message(text: question, isSend: true, date: formattedQuestionDate));
    });

    // Дождитесь завершения добавления ответа
    await Future.delayed(Duration(milliseconds: 200));

    setState(() {
      _messages.insert(0, Message(text: answer, isSend: false, date: formattedAnswerDate));
    });

    var dialogue = fsconnect.collection('dialogue');
    dialogue.add({'text': question, 'isSend': true, 'date': questionTime});
    dialogue.add({'text': answer, 'isSend': false, 'date': answerTime});
  }

  Future<List<Message>> get_dialogue() async {
    var data = await fsconnect.collection("dialogue").get();
    List<Message> ms = [];
    for (var i in data.docs) {
      DateTime date = (i.data()["date"] as Timestamp).toDate();
      ms.add(Message(
        text: i.data()["text"],
        isSend: i.data()["isSend"],
        date: DateFormat('yyyy-MM-dd – kk:mm:ss.SSS').format(date),
      ));
    }
    return ms;
  }
}

