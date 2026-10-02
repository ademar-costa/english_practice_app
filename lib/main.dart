import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Importação do TTS adicionada

void main() {
  runApp(const EnglishPracticeApp());
}

class EnglishPracticeApp extends StatelessWidget {
  const EnglishPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prática de Inglês',
      theme: ThemeData(
        brightness: Brightness.dark, 
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFFFFC107),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PracticeScreen(),
    );
  }
}

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final TextEditingController _portugueseController = TextEditingController();
  String _translatedText = "Hello! This is how the glass app will look.";

  // 1. Instância do FlutterTts
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // 2. Configuração inicial do motor de voz
  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US"); // Define o idioma para Inglês Americano
    await flutterTts.setSpeechRate(0.4); // Deixa a voz um pouco mais lenta para facilitar o entendimento
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  // 3. Função para falar a palavra
  Future<void> _speak(String text) async {
    // Remove pontuações básicas para o leitor não ler coisas como "exclamação"
    String cleanText = text.replaceAll(RegExp(r'[^\w\s]+'), '');
    if (cleanText.isNotEmpty) {
      await flutterTts.speak(cleanText);
    }
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildClickableWords(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    List<String> words = text.split(' ');

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: words.map((word) {
        return InkWell(
          onTap: () {
            // 4. Chama a função de voz ao clicar na palavra!
            _speak(word);
          },
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _portugueseController.dispose();
    flutterTts.stop(); // Importante parar o TTS ao fechar a tela
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text(
          'Praticar Pronúncia',
          style: TextStyle(fontWeight: FontWeight.w300, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/fundo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGlassContainer(
                    padding: const EdgeInsets.all(4),
                    child: TextField(
                      controller: _portugueseController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Digite a frase em Português...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _translatedText = "This will be the translated text";
                        });
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: _buildGlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Traduzir',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.translate, color: Theme.of(context).colorScheme.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Tradução:',
                    style: TextStyle(
                      fontWeight: FontWeight.w300, 
                      fontSize: 16, 
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildClickableWords(_translatedText),
                  const Spacer(),
                  Center(
                    child: InkWell(
                      onTap: () {
                        debugPrint("Iniciou gravação de pronúncia");
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.mic, 
                              size: 40, 
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}