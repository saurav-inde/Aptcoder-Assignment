import 'package:aptcoder/core/app_widgets/appfilledbutton.dart';
import 'package:aptcoder/core/app_widgets/apptextformfield.dart';
import 'package:aptcoder/core/app_widgets/apptexts.dart';
import 'package:aptcoder/core/config/theme.dart';
import 'package:aptcoder/core/models/user.dart';
import 'package:aptcoder/core/services/databse_service.dart';
import 'package:aptcoder/state/lesson_list_and_progress_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _AcademicInfoCard extends StatefulWidget {
  final UserModel user;

  const _AcademicInfoCard({required this.user});

  @override
  State<_AcademicInfoCard> createState() => _AcademicInfoCardState();
}

class _AcademicInfoCardState extends State<_AcademicInfoCard> {
  late String? education;
  late TextEditingController fieldCtrl;
  late TextEditingController goalCtrl;

  @override
  void initState() {
    education = widget.user.educationLevel;
    fieldCtrl = TextEditingController(text: widget.user.fieldOfStudy);
    goalCtrl = TextEditingController(text: widget.user.learningGoal);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Academic Info',
      child: Column(
        children: [
          AppTextFormField(
            controller: fieldCtrl,
            label: 'Field of Study',
            hint: 'Electronics and Communication',
          ),
          const SizedBox(height: 12),

          AppTextFormField(
            controller: goalCtrl,
            label: 'Learning Goal',
            hint: 'Fun',
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.topLeft,
            child: AppText.interLarge('Education Level'),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: education,
            isExpanded: true,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),

            decoration: InputDecoration(
              // labelText: 'Education Level',
              labelStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),

            items: const [
              DropdownMenuItem(value: 'School', child: Text('School')),
              DropdownMenuItem(value: 'College', child: Text('College')),
              DropdownMenuItem(
                value: 'Working Professional',
                child: Text('Working Professional'),
              ),
            ],

            onChanged: (v) {
              education = v;
            },
          ),
          const SizedBox(height: 12),

          AppFilledButton(
            onTap: _saveProfile,
            label: 'Save',
            icon: Icon(Icons.save_alt_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await DatabaseService().updateUserProfile(
      uid,
      educationLevel: education,
      fieldOfStudy: fieldCtrl.text.trim(),
      learningGoal: goalCtrl.text.trim(),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.interMedium(title, weight: FontWeight.w600),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class StudentProfileScreen extends StatelessWidget {
  final UserModel user;

  const StudentProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: AppText.interLarge('Profile', weight: FontWeight.w600),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.02,
        ),
        child: Column(
          children: [
            _ProfileHeader(user: user),
            SizedBox(height: size.height * 0.04),
            _ProfileOptionsCard(user: user),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.edit, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppText.interLarge(user.displayName, weight: FontWeight.w600),
        const SizedBox(height: 4),
        AppText.interMedium(user.email, color: Colors.grey),
      ],
    );
  }
}

class _ProfileOptionsCard extends StatelessWidget {
  final UserModel user;

  const _ProfileOptionsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // _ProfileTile(
          //   icon: Icons.person_outline,
          //   title: 'Account Settings',
          //   onTap: () {
          //     // navigate to account settings
          //   },
          // ),
          // _Divider(),
          _ProfileTile(
            icon: Icons.school_outlined,
            title: 'Education Information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _AcademicInfoSheet(user: user),
                ),
              );
            },
          ),
          _Divider(),
          _ProfileTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () {},
          ),
          _Divider(),
          _ProfileTile(
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () {},
          ),
          _Divider(),
          _ProfileTile(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: AppText.interLarge('Logout', weight: FontWeight.w600),
          content: AppText.interMedium(
            'Are you sure you want to logout?',
            color: Colors.grey.shade700,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
              child: AppText.interLarge('Cancel', color: Colors.grey),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // close dialog
                await FirebaseAuth.instance.signOut();

                /// clear navigation stack
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/onboarding', (route) => false);
              },
              child: AppText.interLarge(
                'Logout',
                color: Colors.red,
                weight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Colors.black;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(child: AppText.interMedium(title, color: color)),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade200);
  }
}

class _AcademicInfoSheet extends StatelessWidget {
  final UserModel user;

  const _AcademicInfoSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: AppText.interMedium('Education Information'),
        backgroundColor: Colors.white,
      ),
      body: _AcademicInfoCard(user: user),
    );
  }
}
