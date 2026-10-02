import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
  // Controlador para pegar o texto digitado pelo usuário
  final TextEditingController _portugueseController = TextEditingController();
  
  // Variável que vai guardar a frase traduzida. 
  // Coloquei um texto de exemplo (mock) por enquanto.
  String _translatedText = "Hello! This is how the app will look.";

  // Função central para a mecânica estilo "Duolingo"
  Widget _buildClickableWords(String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    // Divide a frase em uma lista de palavras
    List<String> words = text.split(' ');

    // O widget Wrap é perfeito aqui porque ele quebra a linha automaticamente
    // se as palavras não couberem na mesma tela (ao contrário do Row)
    return Wrap(
      spacing: 8.0, // Espaço horizontal entre as palavras
      runSpacing: 8.0, // Espaço vertical (quando quebra a linha)
      children: words.map((word) {
        return InkWell(
          onTap: () {
            // No próximo passo, vamos colocar o Text-to-Speech aqui!
            debugPrint("Clicou na palavra: $word");
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              word,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _portugueseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Praticar Pronúncia'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de digitação em português
            TextField(
              controller: _portugueseController,
              decoration: const InputDecoration(
                labelText: 'Digite a frase em Português',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Botão de Tradução
            ElevatedButton(
              onPressed: () {
                // No futuro, chamará a API de tradução do Google Cloud
                setState(() {
                  _translatedText = "This will be the translated text";
                });
              },
              child: const Text('Traduzir'),
            ),
            
            const Divider(height: 48, thickness: 2),
            
            const Text(
              'Tradução (clique nas palavras para ouvir):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // Área onde as palavras clicáveis aparecem
            _buildClickableWords(_translatedText),
            
            const Spacer(),
            
            // Botão de Gravação de Pronúncia
            Center(
              child: FloatingActionButton.large(
                onPressed: () {
                  // No futuro, chamará o gravador de áudio e a avaliação
                  debugPrint("Iniciou gravação de pronúncia");
                },
                tooltip: 'Falar e Avaliar',
                child: const Icon(Icons.mic, size: 36),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}