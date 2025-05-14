import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

enum AttachmentType {
  image,
  video,
  file,
  audio,
  location
}

class AttachmentSelector extends StatelessWidget {
  final Function(AttachmentType type) onAttachmentSelected;

  const AttachmentSelector({
    super.key,
    required this.onAttachmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Attach',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                children: [
                  _buildAttachmentOption(
                    context,
                    'Photo',
                    Icons.image,
                    Colors.purple,
                    () => onAttachmentSelected(AttachmentType.image),
                  ),
                  _buildAttachmentOption(
                    context,
                    'Video',
                    Icons.videocam,
                    Colors.red,
                    () => onAttachmentSelected(AttachmentType.video),
                  ),
                  _buildAttachmentOption(
                    context,
                    'File',
                    Icons.insert_drive_file,
                    Colors.blue,
                    () => onAttachmentSelected(AttachmentType.file),
                  ),
                  _buildAttachmentOption(
                    context,
                    'Audio',
                    Icons.mic,
                    Colors.orange,
                    () => onAttachmentSelected(AttachmentType.audio),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Show modal for attachment selection
  static Future<void> show(
    BuildContext context,
    Function(AttachmentType type) onAttachmentSelected,
  ) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentSelector(
        onAttachmentSelected: (type) {
          Navigator.pop(context);
          onAttachmentSelected(type);
        },
      ),
    );
  }
}