import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:voto_tracker/widgets/candidate_card.dart';
import 'package:voto_tracker/providers/scrutiny_provider.dart';
import 'package:voto_tracker/widgets/control_buttons.dart';
import 'package:voto_tracker/widgets/stats_header.dart';

class CandidatesSection extends StatelessWidget {
  final bool isScrollable;

  const CandidatesSection({super.key, this.isScrollable = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrutinyProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Stats Header
            const StatsHeader(),

            // List
            if (isScrollable)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: provider.candidates.length,
                  itemBuilder: (context, index) {
                    return CandidateCard(
                      index: index,
                      candidate: provider.candidates[index],
                    );
                  },
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.candidates.length,
                itemBuilder: (context, index) {
                  return CandidateCard(
                    index: index,
                    candidate: provider.candidates[index],
                  );
                },
              ),

            // Control Buttons
            const ControlButtons(),
          ],
        );
      },
    );
  }
}
