import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart'; // Il pacchetto per generare colori casuali

class VotiPage extends StatefulWidget {
  @override
  _VotiPageState createState() => _VotiPageState();
}
class VotoData {
  String nome; // Il nome del candidato
  int voti; // Il numero dei voti ricevuti
  charts.Color barColor; // Il colore della barra nel grafico
  VotoData({required this.nome, required this.voti, required this.barColor});
}
class _VotiPageState extends State<VotiPage> {
  // La classe che rappresenta i dati del grafico


  // La lista dei dati del grafico
  List<VotoData> dati = [
  VotoData(nome: "Alice", voti: 10, barColor: charts.ColorUtil.fromDartColor(Colors.blue)),
  VotoData(nome: "Bob", voti: 15, barColor: charts.ColorUtil.fromDartColor(Colors.red)),
  VotoData(nome: "Carlo", voti: 20, barColor: charts.ColorUtil.fromDartColor(Colors.green)),
  VotoData(nome: "Schede bianche", voti: 5, barColor: charts.ColorUtil.fromDartColor(Colors.grey)), // L'elemento per le schede bianche
  VotoData(nome: "Schede nulle", voti: 3, barColor: charts.ColorUtil.fromDartColor(Colors.grey)), // L'elemento per le schede nulle
  ];

  // La variabile che tiene traccia del vincitore
  String vincitore ="";

  // Il controller per il widget TextField
  TextEditingController controller = TextEditingController();

  // Il metodo che crea il widget del grafico
  Widget creaGrafico() {
  // La serie di dati da visualizzare nel grafico
  List<charts.Series<VotoData, String>> serie = [
  charts.Series(
  id: "Voti",
  data: dati,
  domainFn: (VotoData voto, _) => voto.nome, // La funzione che restituisce il nome del candidato
  measureFn: (VotoData voto, _) => voto.voti, // La funzione che restituisce il numero dei voti
  colorFn: (VotoData voto, _) => voto.barColor, // La funzione che restituisce il colore della barra
  labelAccessorFn: (VotoData voto, _) => '${voto.voti}', // La funzione che restituisce il numero dei voti da mostrare sulle barre
  )
  ];

  // Il widget del grafico a barre
  return charts.BarChart(
  serie,
  animate: true, // Abilita le animazioni
  vertical: false, // Rende il grafico orizzontale
  barRendererDecorator: charts.BarLabelDecorator<String>(), // Mostra le etichette sulle barre
  domainAxis: charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()), // Nasconde le etichette sull'asse X
  behaviors: [
  charts.ChartTitle('Grafico dei voti', // Il titolo del grafico
  behaviorPosition: charts.BehaviorPosition.top, // La posizione del titolo
  titleOutsideJustification: charts.OutsideJustification.start, // L'allineamento del titolo
  innerPadding: 18), // Il padding del titolo
        //charts.Legend(), // La legenda del grafico
      ],
  );
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
  dati[index].voti--;
  }
  // Ordina la lista dei dati in base al numero dei voti
  dati.sort((a, b) => b.voti.compareTo(a.voti));
  // Calcola il numero totale dei votanti
  int totale = dati.fold(0, (sum, voto) => sum + voto.voti);
  // Calcola la maggioranza dei voti
  int maggioranza = (totale / 2).ceil();
  // Controlla se il primo candidato ha raggiunto la maggioranza
  if (dati[0].voti >= maggioranza) {
  // Imposta il vincitore con il nome del primo candidato
  vincitore = dati[0].nome;
  } else {
  // Azzera il vincitore
  vincitore = "";
  }
  });
  },
  );
  }

  // Il metodo che crea il widget del TextField
  Widget creaTextField() {
  // Il widget del TextField
  return TextField(
  controller: controller, // Il controller del TextField
  keyboardType: TextInputType.number, // La tipologia di tastiera da mostrare
  decoration: InputDecoration(
  labelText: "Inserisci il numero dei candidati", // L'etichetta del TextField
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
  // Crea un numero casuale di voti per il candidato
  int voti = (10 + i) * (i + 1);
  // Crea un colore casuale per il candidato
  charts.Color barColor = charts.ColorUtil.fromDartColor(randomColor.randomColor());
  // Crea un oggetto VotoData con i dati del candidato
  VotoData voto = VotoData(nome: nome, voti: voti, barColor: barColor);
  // Aggiunge l'oggetto alla lista dei dati
  dati.add(voto);
  }
  // Aggiunge le schede bianche e nulle alla lista dei dati
  dati.add(VotoData(nome: "Schede bianche", voti: 5, barColor: charts.ColorUtil.fromDartColor(Colors.grey)));
  dati.add(VotoData(nome: "Schede nulle", voti: 3, barColor: charts.ColorUtil.fromDartColor(Colors.grey)));
  // Ordina la lista dei dati in base al numero dei voti
  dati.sort((a, b) => b.voti.compareTo(a.voti));
  // Calcola il numero totale dei votanti
  int totale = dati.fold(0, (sum, voto) => sum + voto.voti);
  // Calcola la maggioranza dei voti
  int maggioranza = (totale / 2).ceil();
  // Controlla se il primo candidato ha raggiunto la maggioranza
  if (dati[0].voti >= maggioranza) {
  // Imposta il vincitore con il nome del primo candidato
  vincitore = dati[0].nome;
  } else {
  // Azzera il vincitore
  vincitore = "";
  }
  }
  });
  },
  );
  }

  @override
  Widget build(BuildContext context) {
  // Il widget della pagina
  return Scaffold(
  appBar: AppBar(
  title: Text("Grafico dei voti"),
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
  // Il widget del TextField
  Padding(
  padding: const EdgeInsets.all(8.0),
  child: creaTextField(),
  ),
  // Il widget dei bottoni
  ListView.builder(
  shrinkWrap: true,
  itemCount: dati.length,
  itemBuilder: (context, index) {
  // Il widget di una riga con il nome del candidato e i bottoni per aumentare o decrescere i voti
  return Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
  Text(dati[index].nome),
  creaBottone(dati[index].nome, index, false),
  creaBottone(dati[index].nome, index, true),
  ],
  );
  },
  ),
  // Il widget del messaggio del vincitore
    if (vincitore != "")
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Il vincitore è $vincitore!"),
            ),
  ],
  ),
  );
  }
}