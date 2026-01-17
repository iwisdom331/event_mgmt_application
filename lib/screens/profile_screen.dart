import 'package:appwrite/models.dart';
import 'package:event_planning_app/constants/colors.dart';
import 'package:event_planning_app/container/custom_headertext.dart';
import 'package:event_planning_app/saved_data.dart';
import 'package:event_planning_app/screens/create_event.dart';
import 'package:event_planning_app/screens/login.dart';
import 'package:event_planning_app/screens/manage_events.dart';
import 'package:event_planning_app/screens/saved_events.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final Document? data;
  const ProfileScreen({super.key, this.data});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";

  _ProfileScreenState();
  @override
  void initState() {
    super.initState();
    name = SavedData.getUserName();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isTablet = width > 600;

    final horizontalPadding = isTablet ? 48.0 : 16.0;
    final verticalSpacing = isTablet ? 30.0 : 20.0;
    final avatarRadius = isTablet ? 50.0 : 30.0;
    final fontSizeWelcome = isTablet ? 22.0 : 16.0;
    final fontSizeName = isTablet ? 26.0 : 18.0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBarColor,
        foregroundColor: appBarColor,
        title: const CustomHeadText(text: 'Profile'),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Column(
          children: [
            SizedBox(height: verticalSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: fontSizeWelcome,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        name,
                        style: TextStyle(
                          color: kLavender,
                          fontSize: fontSizeName,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.blueGrey,
                  backgroundImage: widget.data?.data["profileImage"] != null
                      ? NetworkImage(
                          'https://fra.cloud.appwrite.io/v1/storage/buckets/680fb7b70018d4081a4f/files/${widget.data?.data["profileImage"]}/view?project=680531750026ba8d8313',
                        )
                      : null,
                  child: widget.data?.data["profileImage"] == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        )
                      : null,
                )
              ],
            ),
            SizedBox(height: verticalSpacing * 1.5),
            _buildProfileOption(
              context,
              icon: Icons.add_circle_outline,
              label: 'Create Event',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateEvent()),
                );
              },
              fontSize: isTablet ? 22 : 16,
              iconSize: isTablet ? 32 : 24,
            ),
            SizedBox(height: verticalSpacing * 0.75),
            _buildProfileOption(
              context,
              icon: Icons.bookmark_border,
              label: 'Saved Events',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const SavedEvent()));
              },
              fontSize: isTablet ? 22 : 16,
              iconSize: isTablet ? 32 : 24,
            ),
            SizedBox(height: verticalSpacing * 0.75),
            _buildProfileOption(
              context,
              icon: Icons.event_note,
              label: 'Manage Events',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ManageEvents()));
              },
              fontSize: isTablet ? 22 : 16,
              iconSize: isTablet ? 32 : 24,
            ),
            SizedBox(height: verticalSpacing),
            Container(
              height: isTablet ? 110 : 85,
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 100 : 50),
              padding: EdgeInsets.symmetric(vertical: isTablet ? 30 : 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    offset: const Offset(0, 8),
                    color: shadowColor,
                  )
                ],
              ),
              child: Center(
                child: TextButton(
                  onPressed: logoutUser,
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 26 : 19,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future logoutUser() async {
    await account.deleteSession(sessionId: "current");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double fontSize = 16,
    double iconSize = 24,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: iconSize),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
