import 'package:chat_app/screens/private_message_ui.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final User user;
  Future<void> _setToken(String fcmToken) async {
    final userId = user.id;
    await _supabase.client.from('profiles').upsert({
      'user_id': userId,
      'token': fcmToken,
    }, onConflict: 'user_id');
  }

  dynamic userData;
  @override
  void initState() {
    super.initState();
    _supabase.client.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn) {
        await FirebaseMessaging.instance.requestPermission();
        await FirebaseMessaging.instance.getAPNSToken();
        final fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          _setToken(fcmToken);
        }
        FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
          await _setToken(fcmToken);
        });
        FirebaseMessaging.onMessage.listen((payload) {
          final notification = payload.notification;
          if (notification != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("${notification.title}  ${notification.body}"),
              ),
            );
          }
        });
      }
    });
    user = _supabase.client.auth.currentUser!;

    _supabase.client
        .from('users')
        .select()
        .eq('user_id', user.id)
        .single()
        .then((data) {
          setState(() {
            userData = data;
          });
        })
        .catchError((e) {
          // ignore: avoid_print
          print('Error loading data: $e');
        });
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userData['imageUrl']),
          radius: 20,
        ),
        title: Text(userData['username']),
        actions: [
          IconButton(
            onPressed: () async {
              await _supabase.client.auth.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _supabase.client
            .from('users')
            .stream(primaryKey: ['id'])
            .neq('user_id', user.id)
            .order('created_at', ascending: true),
        builder: (bc, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No users yet!!😊"));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Sorry somthing went worng"));
          }
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (ctx, index) {
              return Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Hero(
                    tag: data[index]['imageUrl'],
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(data[index]['imageUrl']),
                      radius: 20,
                    ),
                  ),
                  title: Text(data[index]['username']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => PrivateMessageUi(
                          otherUserId: data[index]['user_id'],
                          imageUrl: data[index]['imageUrl'],
                          username: data[index]['username'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
