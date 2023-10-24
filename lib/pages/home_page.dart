import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:pedagogie/models/session.dart';
import 'package:pedagogie/models/user.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatelessWidget {
  final UserData userData;
  final String token;
  const HomePage({super.key, required this.userData, required this.token});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Bienvenue ${userData.nom}",)),
      body: Calendar(
        id: userData.id,
        token: token,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
              ), //BoxDecoration
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.green),
                accountName: Text(
                  userData.nom.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                accountEmail: Text(userData.email.toString()),
                currentAccountPictureSize: const Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 165, 255, 137),
                  child: Text(
                    userData.nom[0],
                    style: const TextStyle(fontSize: 30.0, color: Colors.blue),
                  ), //Text
                ), //circleAvatar
              ), //UserAccountDrawerHeader
            ), //DrawerHeader
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(' My Profile '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text(' My Course '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text(' Go Premium '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_label),
              title: const Text(' Saved Videos '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text(' Edit Profile '),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('LogOut'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ), //Drawer
    );
  }
}

class Calendar extends StatefulWidget {
  final int id;
  final String token;
  const Calendar({super.key, required this.id, required this.token});
  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late String token;
  late int id;
  DateTime today = DateTime.now();
  late Future<List<Session>> sessionsList;
  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
      sessionsList = getSessions(id, today.toString().split(" ")[0], token);
    });
  }

  @override
  void initState() {
    super.initState();
    token = widget.token;
    id = widget.id;
    sessionsList = getSessions(id, today.toString().split(" ")[0], token);
  }

  Future<List<Session>> getSessions(int user, String date, String token) async {
    final url = "${dotenv.env["url"]}session/user/$user?date=$date";
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    // late Future<Session> sessions;
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      var jsonSession = jsonDecode(response.body)["data"] as List<dynamic>;
      
      return jsonSession.map((session) {
      // debugPrint(session);
        return Session.fromJson(session as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: today,
          selectedDayPredicate: (day) => isSameDay(day, today),
          availableGestures: AvailableGestures.all,
          headerStyle: const HeaderStyle(
              formatButtonVisible: false, titleCentered: true),
          onDaySelected: _onDaySelected,
        ),
        const SizedBox(
          height: 20,
        ),
        Text("Planning ${today.toString().split(" ")[0]}"),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: _list(),
        )
        // DataWidget(sessionsList),
      ],
    );
  }

  Widget _list() {
    return FutureBuilder<List<Session>>(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Session>? sessions = snapshot.data;
          if (sessions != null && sessions.isNotEmpty) {
            // Display the list of sessions
            debugPrint("$sessions.length");
            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                Session session = sessions[index];
                return SessionCard(session: session);
              },
            );
          } else {
            // Empty session list
            return const Text('No sessions available');
          }
          // return Text(snapshot.data.toString());
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
      future: sessionsList,
    );
  }

  Widget SessionCard({required Session session}) {
    return Card(
      child: CheckboxListTile(
        title: Text(session.course.module.libelle),
        subtitle: Text(
            '${session.salle.libelle}/${session.heure_deb}h-${session.heure_fin}h'),
        value: session.validate,
        onChanged: (value) {
          setState(() {
            session.validate = value ?? false;
          });
          
        },
      ),
    );
  }
}
