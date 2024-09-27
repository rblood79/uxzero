import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/selected_widget_model.dart';

class TopPanel extends StatelessWidget {
  const TopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Theme.of(context).colorScheme.onPrimaryFixed,
      child: Consumer<SelectedWidgetModel>(
        builder: (context, selectedWidgetModel, _) {
          return Row(
            children: [
              IconButton(
                icon: Icon(Remix.home_5_line, color: Theme.of(context).colorScheme.onInverseSurface, size: 21),
                onPressed: () {
                  print('Home icon clicked');
                },
              ),

              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Remix.delete_bin_2_line, color: Theme.of(context).colorScheme.onInverseSurface, size: 21),
                onPressed: selectedWidgetModel.canRedo
                    ? () {
                        selectedWidgetModel.deleteSelectedWidget();
                      }
                    : null,
              ),
              IconButton(
                icon: Icon(Remix.arrow_go_back_line, color: Theme.of(context).colorScheme.onInverseSurface, size: 21),
                onPressed: selectedWidgetModel.canUndo
                    ? () {
                        selectedWidgetModel.undo();
                      }
                    : null,
              ),
              IconButton(
                icon: Icon(Remix.arrow_go_forward_line, color: Theme.of(context).colorScheme.onInverseSurface, size: 21),
                onPressed: selectedWidgetModel.canRedo
                    ? () {
                        selectedWidgetModel.redo();
                      }
                    : null,
              ),
              
            ],
          );
        },
      ),
    );
  }
}
