import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

//Definizione Attività
class TodoItem {
  String title;
  bool isCompleted;
  bool isImportant;

  TodoItem({
    required this.title,
    this.isCompleted = false,
    this.isImportant = false,
  });
}

//Funzionalità Applicazione
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

// --- 3. SCHERMATA ELENCO ATTIVITÀ (S2, S3, S4) ---
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _tasks = [];

  // Metodo per calcolare quante attività sono completate
  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  //Aggiornare lo stato di un'attività
  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  //Eliminare un'attività con conferma
  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: const Text('Sei sicuro di voler eliminare questa attività?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // S4 Variante: Rinuncia
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _tasks.removeAt(index);
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  //Aprire la schermata di creazione
  void _navigateToCreateScreen() async {
    // Aspettiamo che la schermata di creazione ci restituisca un nuovo TodoItem
    final newTask = await Navigator.of(context).push<TodoItem>(
      MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
    );

    // Se l'utente ha confermato la creazione
    if (newTask != null) {
      setState(() {
        _tasks.add(newTask);
      });

      //Messaggio temporaneo di conferma (SnackBar)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attività aggiunta con successo!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le mie attività'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Intestazione con il conteggio (S2)
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: double.infinity,
            child: Text(
              'Completate: $_completedCount su ${_tasks.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          // Lista delle attività
          Expanded(
            child: _tasks.isEmpty
            // S2 Variante: Nessuna attività
                ? const Center(
              child: Text(
                'Nessuna attività presente.\nPremi il tasto + per aggiungerne una.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  // S2: Titolo, stato e importanza ben distinguibili
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontWeight: task.isImportant
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: task.isImportant
                      ? const Text('Importante', style: TextStyle(color: Colors.red))
                      : null,
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) => _toggleTaskStatus(index),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateScreen,
        tooltip: 'Aggiungi Attività',
        child: const Icon(Icons.add),
      ),
    );
  }
}

//SCHERMATA CREAZIONE ATTIVITÀ (S1)
class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  // Chiave per validare il form
  final _formKey = GlobalKey<FormState>();

  // Controller per leggere il testo inserito
  final _titleController = TextEditingController();

  // Stato del checkbox "Importante"
  bool _isImportant = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTask() {
    // S1 Variante - Titolo mancante: triggera la validazione visiva
    if (_formKey.currentState!.validate()) {
      // Se il form è valido, creiamo l'oggetto e lo passiamo indietro
      final newTask = TodoItem(
        title: _titleController.text.trim(),
        isImportant: _isImportant,
      );
      Navigator.of(context).pop(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova Attività'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titolo dell\'attività *',
                  border: OutlineInputBorder(),
                ),
                // Validazione: controlla che non sia vuoto
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Il titolo è obbligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Segna come Importante'),
                value: _isImportant,
                onChanged: (bool? value) {
                  setState(() {
                    _isImportant = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveTask,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Crea Attività', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}