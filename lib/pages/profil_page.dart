import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.black),
          onPressed: () =>
              Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
            bottom: 100),
        child: Column(
          children: [

            const SizedBox(height: 25),

            // PROFILE IMAGE
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: 110,
                  width: 110,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE5E7EB),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  height: 34,
                  width: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 18,
                    color: Colors.white,
                  ),
                )
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              "Alex Wisnu",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            const Text(
              "Member since 2023",
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey),
            ),

            const SizedBox(height: 30),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 20),
              child: Column(
                children: [

                  // USERNAME FIELD
                  buildProfileField(
                    icon: Icons.badge,
                    label: "User Name",
                    value: "Alex Wisnu",
                  ),

                  const SizedBox(height: 20),

                  // EMAIL FIELD
                  buildProfileField(
                    icon: Icons.mail,
                    label: "Email",
                    value:
                        "alex.wisnu@gmail.com",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 20),
              child: Column(
                children: [

                  buildMenuItem(
                    icon: Icons.edit_square,
                    title: "Edit Profile",
                  ),

                  const SizedBox(height: 12),

                  buildMenuItem(
                    icon: Icons.settings,
                    title: "Settings",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  label: const Text(
                    "Log Out",
                    style: TextStyle(
                        color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Colors.red),
                    padding:
                        const EdgeInsets
                            .symmetric(
                                vertical: 14),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(10),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildProfileField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius:
                BorderRadius.circular(10),
            border: Border.all(
                color: const Color(
                    0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                      fontWeight:
                          FontWeight.w500),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
            color:
                const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets
                        .all(6),
                decoration:
                    BoxDecoration(
                  color: Colors.blue
                      .withOpacity(
                          0.1),
                  borderRadius:
                      BorderRadius
                          .circular(6),
                ),
                child: Icon(icon,
                    size: 18,
                    color:
                        Colors.blue),
              ),
              const SizedBox(
                  width: 10),
              Text(
                title,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .w500,
                ),
              ),
            ],
          ),
          const Icon(
              Icons.chevron_right,
              color: Colors.grey),
        ],
      ),
    );
  }
}