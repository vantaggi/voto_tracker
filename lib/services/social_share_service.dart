import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:voto_tracker/models/candidate.dart';
import 'package:voto_tracker/widgets/social_results_card.dart';

class SocialShareService {
    static Future<void> shareResults({
        required List<Candidate> candidates, 
        required int totalVotes,
        String? winner
    }) async {
        final controller = ScreenshotController();
        
        try {
            final double pixelRatio = 3.0; // High res
            
            final Uint8List image = await controller.captureFromWidget(
                SocialResultsCard(candidates: candidates, totalVotes: totalVotes, winner: winner),
                delay: const Duration(milliseconds: 10),
                pixelRatio: pixelRatio
            );
            
            final directory = await getTemporaryDirectory();
            final fileName = 'voto_tracker_share_${DateTime.now().millisecondsSinceEpoch}.png';
            final file = File('${directory.path}/$fileName');
            await file.writeAsBytes(image);
            
            await Share.shareXFiles(
                [XFile(file.path)], 
                text: winner != null 
                    ? '🏆 VITTORIA! ${winner} ha vinto lo scrutinio!'
                    : '📊 Aggiornamento scrutinio in tempo reale - Voto Tracker'
            );
            
        } catch(e) {
            debugPrint("Error sharing image: $e");
        }
    }
}
