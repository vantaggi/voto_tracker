import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:voto_tracker/settings.dart'; // Il pacchetto per generare colori casuali

void main() => runApp(MaterialApp(
      home: const VotiPage(),
      theme: ThemeData.dark(),
      //darkTheme: ThemeData.dark(),
    ));

class VotiPage extends StatefulWidget {
  const VotiPage({super.key});

  @override
  _VotiPageState createState() => _VotiPageState();
}

class VotoData {
  String nome; // Il nome del candidato
  int voti; // Il numero dei voti ricevuti
  Color barColor; // Il colore della barra nel grafico
  VotoData({required this.nome, required this.voti, required this.barColor});
}

class _VotiPageState extends State<VotiPage> {
  // La classe che rappresenta i dati del grafico

  Settings settings = Settings();

  // La lista dei dati del grafico
  List<VotoData> dati = [
    VotoData(
        nome: "Farneti",
        voti: 0,
        barColor: Colors.blue),
    VotoData(
        nome: "Provvedi",
        voti: 0,
        barColor: Colors.red),
    VotoData(
        nome: "Cappannelli",
        voti: 0,
        barColor: Colors.green),
    VotoData(
        nome: "Marcelli",
        voti: 0,
        barColor: Colors.amber),
    VotoData(
        nome: "bianche",
        voti: 0, barColor: Colors.grey),
    // L'elemento per le schede bianche
    VotoData(nome: "nulle", voti: 0, barColor: Colors.black38),
    // L'elemento per le schede nulle
  ];

  // La variabile che tiene traccia del vincitore
  String vincitore = "";
  int totaleVotiAssegnati = 0;
  int votiRimanenti = 0;
  int soglia = 0;

  // Il controller per il widget TextField
  TextEditingController controller = TextEditingController();

  // Il metodo che crea il widget del grafico
  Widget creaGrafico() {
    BarChartData data = BarChartData(
        maxY: dati[0].voti + (dati[0].voti * 20 / 100),
        barGroups: [
          for (VotoData dato in dati)
            BarChartGroupData(x: dati.indexOf(dato), barRods: [
              BarChartRodData(
                toY: dato.voti.toDouble(),
                color: dato.barColor,
              )
            ], showingTooltipIndicators: [
              0
            ])
        ],
        titlesData: const FlTitlesData(
          show: false,
        ),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
                rotateAngle: -90,
                tooltipBorder: const BorderSide(
                  width: 2,
                  color: Colors.white30,
                ),
                tooltipPadding: const EdgeInsets.all(8.0),
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  String value = dati[groupIndex].nome +
                      " " +
                      dati[groupIndex].voti.toString();

                  return BarTooltipItem(
                      value,
                      TextStyle(
                        color: dati[groupIndex].barColor,
                        fontWeight: FontWeight.bold,
                      ));
                })));

    return Stack(
      children: [
        RotatedBox(
          quarterTurns: 1,
          child: BarChart(
            data,
          ),
        ),
      ],
    );
  }

  void calcolaVotanti() {
    // Ordina la lista dei dati in base al numero dei voti
    dati.sort((a, b) => b.voti.compareTo(a.voti));
    // Calcola il numero totale dei votanti
    totaleVotiAssegnati = dati.fold(0, (sum, voto) => sum + voto.voti);
    // Calcola la maggioranza dei voti
    votiRimanenti = settings.numVotanti - totaleVotiAssegnati;
    // Controlla se il primo candidato ha raggiunto la maggioranza
    if (dati[0].voti > dati[1].voti + votiRimanenti) {
      // Imposta il vincitore con il nome del primo candidato
      vincitore = dati[0].nome;
    } else {
      // Azzera il vincitore
      vincitore = "";
    }
  }

  // Il metodo che crea il widget del bottone
  Widget creaBottone(String nome, int index, bool incrementa) {
    // Il widget del bottone
    return ElevatedButton(
      child: Text(incrementa ? "+" : "-"), // Il testo del bottone
      onPressed: () {
        // La logica da eseguire quando il bottone viene premuto
        setState(() {
          // Modifica il valore dei voti in base al parametro incrementa
          if (incrementa) {
            dati[index].voti++;
          } else {
            if (dati[index].voti != 0) dati[index].voti--;
          }
          calcolaVotanti();
          calcolaVotiperVincere();
        });
      },
    );
  }

  // Il metodo che crea il widget del TextField
  Widget creaCandidateField(int index) {
    // Il widget del TextField
    TextEditingController controllerCandidate = TextEditingController();
    return TextField(
      // Il controller per il widget TextField
      controller: controllerCandidate,

      // Il controller del TextField
      keyboardType: TextInputType.text,
      // La tipologia di tastiera da mostrare
      decoration: InputDecoration(
        labelText: dati[index].nome,
        // L'etichetta del TextField
        border: const OutlineInputBorder(), // Il bordo del TextField
      ),
      onSubmitted: (value) {
        // La logica da eseguire quando il valore viene inviato
        setState(() {
          dati[index].nome = value;
        });
      },
    );
  }

  // Il metodo che crea il widget del TextField
  Widget creaTextField() {
    // Il widget del TextField
    return TextField(
      controller: controller,
      // Il controller del TextField
      keyboardType: TextInputType.number,
      // La tipologia di tastiera da mostrare
      decoration: const InputDecoration(
        labelText: "Inserisci il numero dei candidati",
        // L'etichetta del TextField
        border: OutlineInputBorder(), // Il bordo del TextField
      ),
      onSubmitted: (value) {
        // La logica da eseguire quando il valore viene inviato
        setState(() {
          // Converte il valore in un numero intero
          int numero = int.tryParse(value) ?? 0;
          // Controlla se il numero è valido
          if (numero > 0) {
            // Crea un generatore di colori casuali
            RandomColor randomColor = RandomColor();
            // Svuota la lista dei dati
            dati.clear();
            // Aggiunge il numero di candidati richiesto alla lista dei dati
            for (int i = 0; i < numero; i++) {
              // Crea un nome casuale per il candidato
              String nome = "Candidato ${i + 1}";
              // Partono tutti da 0
              int voti = 0;
              // Crea un colore casuale per il candidato
              Color barColor = randomColor.randomColor();
              // Crea un oggetto VotoData con i dati del candidato
              VotoData voto =
                  VotoData(nome: nome, voti: voti, barColor: barColor);
              // Aggiunge l'oggetto alla lista dei dati
              dati.add(voto);
            }
            // Aggiunge le schede bianche e nulle alla lista dei dati
            dati.add(VotoData(
                nome: "Schede bianche", voti: 0, barColor: Colors.grey));
            dati.add(
                VotoData(nome: "Schede nulle", voti: 0, barColor: Colors.grey));
            calcolaVotanti();
          }
        });
      },
    );
  }

  Widget colorValue(int index) {
    TextEditingController controllerColorValue = TextEditingController();
    return Center(
        child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: dati[index].barColor,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white, width: 5),
            ),
            alignment: Alignment.center,
            child: TextField(
              // Il controller per il widget TextField
              controller: controllerColorValue,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              expands: true,
              minLines: null,
              maxLines: null,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              // Il controller del TextField
              keyboardType: TextInputType.number,
              // La tipologia di tastiera da mostrare
              decoration: InputDecoration(
                hintText: dati[index].voti.toString(),
                // L'etichetta del TextField
                border: InputBorder.none, // Il bordo del TextField
              ),
              onSubmitted: (value) {
                // La logica da eseguire quando il valore viene inviato
                setState(() {
                  int numeroVoti = int.tryParse(value) ?? 0;
                  dati[index].voti = numeroVoti;
                });
                calcolaVotanti();
              },
            )));
  }

  int calcolaVotiperVincere() {
    soglia = ((dati[1].voti + votiRimanenti + 1 - dati[0].voti) / 2).round();
    return soglia;
  }

  @override
  Widget build(BuildContext context) {
    // Il widget della pagina
    return Directionality(
      textDirection: TextDirection.ltr,
      // This is the default text direction for Flutter
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Voto Tracker"),
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (context) => SettingsPage(
                        settings: settings,
                      ),
                    ))
                    .then((value) => setState(() {})),
                icon: const Icon(Icons.settings))
          ],
        ),
        body: Column(
          children: [
            // Il widget del grafico
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: creaGrafico(),
              ),
            ),

            //widget che mostra il numero dei votanti
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Votanti totali: ${settings.numVotanti}"),
                  // Il widget del messaggio del vincitore
                  if (vincitore != "") Text("Il vincitore è $vincitore!"),
                  if (vincitore == "") Text("Voti per vincere $soglia"),
                  Text("Votanti rimasti: $votiRimanenti"),
                ],
              ),
            ),

            // Il widget dei bottoni
            ListView.builder(
              shrinkWrap: true,
              itemCount: settings.numPartecipanti,
              itemBuilder: (context, index) {
                // Il widget di una riga con il nome del candidato e i bottoni per aumentare o decrescere i voti
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: creaCandidateField(index)),
                    creaBottone(dati[index].nome, index, false),
                    colorValue(index),
                    creaBottone(dati[index].nome, index, true),
                    Text((dati[index].voti - dati[0].voti).toString()),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
