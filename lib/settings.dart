import "package:flutter/material.dart";

class SettingsPage extends StatefulWidget {
  Settings settings;

  SettingsPage({super.key, required this.settings});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget creaOpzioneNumPartecipanti() {
    return ListTile(
      title: const Text("Numero partecipanti"),
      trailing: Text(
        "${widget.settings.numPartecipanti}",
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textScaler: const TextScaler.linear(1.5),
      ),
      subtitle: Slider(
        value: widget.settings.numPartecipanti.toDouble(),
        onChanged: (value) {
          setState(() {
            widget.settings.updateNumPartecipanti(value.floor());
          });
        },
        min: 2,
        max: 10,
        divisions: 9,
      ),
    );
  }

  Widget creaOpzioneNumVotanti() {
    TextEditingController numVotantiController =
        TextEditingController(text: widget.settings.numVotanti.toString());
    return ListTile(
      title: const Text("Numero Votanti"),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          controller: numVotantiController,
          textAlign: TextAlign.center,
          maxLines: 1,
          keyboardType: TextInputType.number,
          onSubmitted: (value) => setState(() {
            widget.settings.updateNumVotanti(int.parse(value));
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Impostazioni"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          creaOpzioneNumPartecipanti(),
          creaOpzioneNumVotanti(),
        ],
      ),
    );
  }
}

class Settings {
  bool _schedeBianche;
  bool _schedeNulle;
  int _numPartecipanti;
  int _numVotanti;

  bool get schedeBianche => _schedeBianche;
  bool get schedeNulle => _schedeNulle;
  int get numPartecipanti => _numPartecipanti;
  int get numVotanti => _numVotanti;

  Settings(
      {int numPartecipanti = 6,
      bool schedeBianche = true,
      bool schedeNulle = true,
      int numVotanti = 100})
      : _numPartecipanti = numPartecipanti,
        _schedeNulle = schedeNulle,
        _schedeBianche = schedeBianche,
        _numVotanti = numVotanti;

  void updateNumPartecipanti(int num) {
    if (num > 1) {
      _numPartecipanti = num;
    }
  }

  void updateNumVotanti(int num) {
    if (num > 1) {
      _numVotanti = num;
    }
  }

  void updateSchedeBianche(bool val) {
    _schedeBianche = val;
  }

  void updateSchedeNulle(bool val) {
    _schedeNulle = val;
  }
}