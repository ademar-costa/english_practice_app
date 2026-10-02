import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:record/record.dart'; // Nova importação
import 'package:permission_handler/permission_handler.dart'; // Nova importação
import 'package:path_provider/path_provider.dart'; // Nova importação

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
  String _translatedText = ""; 
  bool _isTranslating = false;

  final FlutterTts flutterTts = FlutterTts();
  final GoogleTranslator translator = GoogleTranslator();
  
  // Instância do gravador de áudio
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioFilePath;

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

  Future<void> _translateText() async {
    final textToTranslate = _portugueseController.text.trim();
    if (textToTranslate.isEmpty) return;

    setState(() { _isTranslating = true; });

    try {
      var translation = await translator.translate(textToTranslate, from: 'pt', to: 'en');
      setState(() {
        _translatedText = translation.text;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() { _isTranslating = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao traduzir. Verifique a sua internet.')),
        );
      }
    }
  }

  // Função para controlar a gravação
  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        // Se está a gravar, mandamos parar
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _audioFilePath = path;
        });
        debugPrint("Áudio guardado com sucesso em: $_audioFilePath");
        
        // Aqui, no próximo passo, enviaremos este ficheiro para a Azure!
        
      } else {
        // Pede permissão ao Android
        final status = await Permission.microphone.request();
        
        if (status.isGranted) {
          // Descobre a pasta temporária do telemóvel
          final dir = await getApplicationDocumentsDirectory();
          final filePath = '${dir.path}/audio_pronuncia.wav';
          
          // Inicia a gravação configurada exatamente para o padrão da Azure API
          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.wav,
              sampleRate: 16000,
              numChannels: 1, // Mono
            ),
            path: filePath,
          );
          
          setState(() {
            _isRecording = true;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('É necessário permitir o uso do microfone.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Erro na gravação: $e");
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
    _audioRecorder.dispose(); // Limpamos o gravador da memória
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
                        onTap: _isTranslating ? null : _translateText,
                        borderRadius: BorderRadius.circular(30),
                        child: _buildGlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                    
                    // Atualização visual do botão de microfone
                    Center(
                      child: GestureDetector(
                        onTap: _toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: _isRecording ? 90 : 80, // Aumenta de tamanho enquanto grava
                          width: _isRecording ? 90 : 80,
                          decoration: BoxDecoration(
                            // Fica vermelho e opaco a gravar, ou mantém o amarelo translúcido
                            color: _isRecording 
                                ? Colors.redAccent.withOpacity(0.8) 
                                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                            boxShadow: _isRecording 
                                ? [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)] 
                                : [],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic, 
                            size: 40, 
                            color: Colors.white,
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