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

  Widget creaOpzioneNumPartecipanti(){
     TextEditingController numPartecipantiController = TextEditingController(text: widget.settings.numPartecipanti.toString());
    return ListTile(
      title: const Text("Numero partecipanti"),
      trailing: Text("${widget.settings.numPartecipanti}"),
      /*trailing: SizedBox(
        width: 40,
        child: TextField(
          keyboardType: TextInputType.number,
          controller: numPartecipantiController,
          textAlign: TextAlign.center,
          maxLength: 2,
          maxLines: 1,
          onSubmitted: (value) => setState(() {
            widget.settings.updateNumPartecipanti(int.parse(numPartecipantiController.text));
          }),
        ),
      ),*/
      subtitle: Slider(value: widget.settings.numPartecipanti.toDouble(), onChanged: (value){

        setState(() {
          widget.settings.updateNumPartecipanti(value.floor());
        });

      }, min: 2, max: 10, divisions: 9, ),
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
        ],
      ),
    );
  }
}

class Settings{
  bool _schedeBianche;
  bool _schedeNulle;
  int _numPartecipanti;

  bool get schedeBianche => _schedeBianche;
  bool get schedeNulle => _schedeNulle;
  int get numPartecipanti => _numPartecipanti;

  Settings({int numPartecipanti = 4,bool schedeBianche = true, bool schedeNulle = true}) : _numPartecipanti = numPartecipanti, _schedeNulle = schedeNulle, _schedeBianche = schedeBianche;
  
  updateNumPartecipanti(int num){
    if(num > 1){
      _numPartecipanti = num;
    }
  }
  
  updateSchedeBianche(bool val){
    _schedeBianche = val;
  }

  updateSchedeNulle(bool val){
    _schedeNulle = val;
  }

}