import 'package:flutter/material.dart';
import '../../../res/app_widget/custom_app_bar.dart';
import '../../../res/app_widget/custom_app_text.dart';
import '../../../utils/app_color.dart';
import '../../../utils/app_constent.dart';
import '../../home/widget/custom_drawer.dart';

class ReferenceLevelsScreen extends StatefulWidget {
  const ReferenceLevelsScreen({super.key});

  @override
  State<ReferenceLevelsScreen> createState() => _ReferenceLevelsScreenState();
}

class _ReferenceLevelsScreenState extends State<ReferenceLevelsScreen> {
  // Mock Data Generation: Simulating Levels 1-25
  // In a real app, this would come from an API
  final List<Map<String, dynamic>> levelsData = List.generate(25, (index) {
    int levelNumber = index + 1;

    // Example logic from prompt: "if level one inside 2 refrence show 2 user"
    // We are generating random user counts for demo purposes
    int userCount = (levelNumber == 1) ? 2 : (levelNumber * 3) % 7;

    return {
      "level": levelNumber,
      "users": List.generate(userCount, (userIndex) => {
        "name": "User ${levelNumber}-${userIndex + 1}",
        "id": "REF-${levelNumber}00${userIndex + 1}",
        "joinDate": "12 Jan 2026",
        "status": "Active",
        "earnings": "\$${(userIndex + 1) * 50}.00"
      }),
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(title: AppConst.appName),
      drawer: CustomDrawer(currentRoute: 'reference_levels'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Using your custom screen gradient
        decoration: BoxDecoration(
          gradient: AppColor.screenGradientBgColor,
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            physics: const BouncingScrollPhysics(),
            itemCount: levelsData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = levelsData[index];
              return _LevelExpansionTile(
                level: data['level'],
                users: data['users'],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LevelExpansionTile extends StatelessWidget {
  final int level;
  final List<dynamic> users;

  const _LevelExpansionTile({
    required this.level,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Using your card gradient
        gradient: AppColor.cardGradientBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Theme(
        // Hides the default divider lines of ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColor.white,
          collapsedIconColor: AppColor.grey300,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.bold(
                "Level $level",
                fontSize: 18,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AppText.small(
                  "${users.length} References",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          children: [
            if (users.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppText.regular(
                  "No references found in this level.",
                  color: AppColor.grey300,
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...users.map((user) => _UserReferenceCard(user: user)),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _UserReferenceCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserReferenceCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.secondaryPrimaryColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Avatar / Icon
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primaryColor.withOpacity(0.2),
              border: Border.all(color: AppColor.primaryColor),
            ),
            child: const Icon(
              Icons.person,
              color: AppColor.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.medium(
                      user['name'],
                      fontWeight: FontWeight.w600,
                    ),
                    AppText.small(
                      user['status'],
                      color: AppColor.success, // Using your semantic color
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.small(
                      "ID: ${user['id']}",
                      color: AppColor.grey300,
                    ),
                    AppText.small(
                      user['joinDate'],
                      color: AppColor.grey500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}