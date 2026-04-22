import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
const ProfilePage({super.key});

@override
State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

final user = FirebaseAuth.instance.currentUser;

final nameController = TextEditingController();
final phoneController = TextEditingController();

File? imageFile;

final firestore = FirebaseFirestore.instance;

@override
void initState() {
super.initState();
loadUserData();
}

Future<void> loadUserData() async {

final doc = await firestore
    .collection('users')
    .doc(user!.uid)
    .get();

if (doc.exists) {

  final data = doc.data();

  nameController.text = data?['name'] ?? "";
  phoneController.text = data?['phone'] ?? "";

  setState(() {});
}

}

Future<void> saveUserData() async {

await firestore
    .collection('users')
    .doc(user!.uid)
    .set({
  'name': nameController.text,
  'phone': phoneController.text,
  'email': user!.email
}, SetOptions(merge: true));

}

Future<void> pickImage() async {

final picked =
    await ImagePicker().pickImage(
  source: ImageSource.gallery,
);

if (picked != null) {

  setState(() {
    imageFile = File(picked.path);
  });
}

}

void editField(
String title,
TextEditingController controller) {

showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: Text("Edit $title"),
    content: TextField(
      controller: controller,
    ),
    actions: [

      TextButton(
        onPressed: () =>
            Navigator.pop(context),
        child: const Text("Cancel"),
      ),

      TextButton(
        onPressed: () async {

          await saveUserData();

          setState(() {});

          Navigator.pop(context);
        },
        child: const Text("Save"),
      )
    ],
  ),
);

}

void logout() async {

await FirebaseAuth.instance.signOut();

if (!mounted) return;

Navigator.pushReplacementNamed(
  context,
  '/login',
);

}

Widget infoItem(
String label,
String value,
IconData icon,
VoidCallback onTap) {

return GestureDetector(

  onTap: onTap,

  child: Container(
    padding:
        const EdgeInsets.all(16),

    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(0xFFEAEAEA),
        ),
      ),
    ),

    child: Row(
      children: [

        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                const Color(0xFF13EC80)
                    .withOpacity(0.15),
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color:
                const Color(0xFF13EC80),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value.isEmpty ? "-" : value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
      ],
    ),
  ),
);

}

@override
Widget build(BuildContext context) {

return Scaffold(

  backgroundColor:
      const Color(0xFFF6F8F7),

  body: SafeArea(

    child: Column(
      children: [

        Padding(
          padding:
              const EdgeInsets.all(16),

          child: Row(
            children: [

              IconButton(
                icon:
                    const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const Expanded(
                child: Center(
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Icon(Icons.settings),
            ],
          ),
        ),

        Container(
          color: Colors.white,
          padding:
              const EdgeInsets.all(20),

          child: Column(
            children: [

              Stack(
                children: [

                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        imageFile != null
                            ? FileImage(imageFile!)
                            : const NetworkImage(
                                "https://i.pravatar.cc/150")
                            as ImageProvider,
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child:
                        GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding:
                            const EdgeInsets.all(6),
                        decoration:
                            const BoxDecoration(
                          color: Color(0xFF13EC80),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 12),

              Text(
                nameController.text.isEmpty
                    ? "Your Name"
                    : nameController.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user?.email ?? "-",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [

                infoItem(
                  "Full Name",
                  nameController.text,
                  Icons.person,
                  () => editField(
                    "Name",
                    nameController,
                  ),
                ),

                infoItem(
                  "Phone Number",
                  phoneController.text,
                  Icons.phone,
                  () => editField(
                    "Phone",
                    phoneController,
                  ),
                ),

                infoItem(
                  "Email",
                  user?.email ?? "",
                  Icons.mail,
                  () {},
                ),

                const Spacer(),

                Padding(
                  padding:
                      const EdgeInsets.all(16),

                  child: SizedBox(
                    width: double.infinity,
                    height: 50,

                    child:
                        ElevatedButton.icon(
                      onPressed: logout,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red.shade50,
                        foregroundColor:
                            Colors.red,
                      ),

                      icon: const Icon(Icons.logout),

                      label:
                          const Text("Logout"),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    ),
  ),
);

}
}