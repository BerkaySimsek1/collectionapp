import 'package:flutter/material.dart';

// custom appbar
class ProjectAppbar extends StatelessWidget implements PreferredSizeWidget {
  const ProjectAppbar({
    super.key,
    required this.titletext,
  });
  final String titletext;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        titletext,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
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

// custom add floatingactionbutton decoration
class AddFloatingDecoration extends StatelessWidget {
  const AddFloatingDecoration({required this.buttonText, super.key});
  final String buttonText;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
          color: Colors.deepPurple, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(
            Icons.add,
            color: Colors.white,
          ),
          Text(
            buttonText,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// custom final floatingactionbutton decoration
class FinalFloatingDecoration extends StatelessWidget {
  const FinalFloatingDecoration({required this.buttonText, super.key});
  final String buttonText;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 380,
      decoration: BoxDecoration(
          color: Colors.deepPurple, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          buttonText,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
