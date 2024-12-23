import "package:flutter/material.dart";

// custom appbar
class ProjectAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ProjectAppbar({
    super.key,
    required this.titleText,
  });
  final String titleText;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(titleText, style: ProjectTextStyles.appBarTextStyle),
      leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.deepPurple,
          )),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ProjectTextStyles {
  static const TextStyle appBarTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
  );
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const TextStyle cardHeaderTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.black,
  );
  static const TextStyle cardDescriptionTextStyle = TextStyle(
    fontSize: 15,
    color: Colors.black,
  );
  static TextStyle subtitleTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey[700],
  );
}

class ProjectDecorations {
  static ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    elevation: 4,
    backgroundColor: Colors.deepPurple,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

// custom final floatingactionbutton decoration
class FinalFloatingDecoration extends StatelessWidget {
  const FinalFloatingDecoration(
      {required this.buttonText, this.progress, super.key});
  final String buttonText;
  final bool? progress;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 380,
      decoration: BoxDecoration(
          color: Colors.deepPurple, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: progress == true
            // indicator appears when loading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(
                buttonText,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
      ),
    );
  }
}
