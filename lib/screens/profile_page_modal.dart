import 'dart:ui';
import 'package:flutter/material.dart';
import 'profile_page.dart';

class ProfilePageModal extends StatelessWidget {
  final VoidCallback onClose;
  const ProfilePageModal({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 420,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: ProfilePage(startInEditMode: true, onClose: onClose),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
