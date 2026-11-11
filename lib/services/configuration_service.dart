import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voto_tracker/models/candidate.dart';

class ConfigurationService {
  
  static Future<List<Candidate>?> importConfiguration() async {
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (picked != null) {
        // readAsBytes funziona anche con gli URI content:// di Android, dove
        // `path` può essere null.
        final content = utf8.decode(await picked.readAsBytes());
        List<dynamic> jsonList = jsonDecode(content);
        return jsonList.map((e) => Candidate.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error importing configuration: $e");
    }
    return null;
  }

  static Future<void> exportConfiguration(List<Candidate> candidates) async {
    try {
      // Create a clean list with 0 votes for configuration template
      final configList = candidates.map((c) {
          return Candidate(
              name: c.name, 
              votes: 0, 
              color: c.color,
              previousPercentage: c.previousPercentage
          );
      }).toList();

      String jsonString = jsonEncode(configList.map((e) => e.toJson()).toList());
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/voto_tracker_config.json');
      await file.writeAsString(jsonString);

      await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path)], text: 'Voto Tracker Configuration'));
    } catch (e) {
       debugPrint("Error exporting configuration: $e");
    }
  }
}
