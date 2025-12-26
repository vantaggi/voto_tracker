import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voto_tracker/models/candidate.dart';

class ConfigurationService {
  
  static Future<List<Candidate>?> importConfiguration() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
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

      await Share.shareXFiles([XFile(file.path)], text: 'Voto Tracker Configuration');
    } catch (e) {
       debugPrint("Error exporting configuration: $e");
    }
  }
}
