import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart'; // 1. Nova importação do tradutor

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
  
  // A frase traduzida começa vazia agora
  String _translatedText = ""; 
  
  // 2. Variável para mostrar o ícone de carregamento durante a tradução
  bool _isTranslating = false;

  final FlutterTts flutterTts = FlutterTts();
  
  // 3. Instância do Tradutor
  final GoogleTranslator translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    String cleanText = text.replaceAll(RegExp(r'[^\w\s]+'), '');
    if (cleanText.isNotEmpty) {
      await flutterTts.speak(cleanText);
    }
  }

  // 4. Função Assíncrona de Tradução
  Future<void> _translateText() async {
    final textToTranslate = _portugueseController.text.trim();
    
    // Se o campo estiver vazio, não faz nada
    if (textToTranslate.isEmpty) return;

    // Atualiza o ecrã para mostrar o modo "a carregar"
    setState(() {
      _isTranslating = true;
    });

    try {
      // Chama a API de tradução de PT para EN
      var translation = await translator.translate(textToTranslate, from: 'pt', to: 'en');
      
      // Atualiza o ecrã com o resultado
      setState(() {
        _translatedText = translation.text;
        _isTranslating = false;
      });
    } catch (e) {
      // Em caso de erro (ex: sem internet), voltamos ao normal
      debugPrint("Erro na tradução: $e");
      setState(() {
        _isTranslating = false;
      });
      
      // Mostra um aviso ao utilizador
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao traduzir. Verifique a sua internet.')),
        );
      }
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
          onTap: () => _speak(word),
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
    flutterTts.stop();
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
      // Esconder o teclado quando se toca fora do campo de texto
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
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
                        // 5. O botão agora chama a nossa função de tradução e está desativado se estiver a carregar
                        onTap: _isTranslating ? null : _translateText,
                        borderRadius: BorderRadius.circular(30),
                        child: _buildGlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 6. Mostramos uma roda de carregamento ou o texto do botão
                              if (_isTranslating)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              else ...[
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
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Só mostra o título "Tradução:" se houver texto traduzido
                    if (_translatedText.isNotEmpty) ...[
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
                    ],
                    
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
      ),
    );
  }
}