import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttersearch/search_bloc.dart';
import 'package:search_user_repository/search_user_repository.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SearchUserRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => SearchBloc(
                  searchUserRepository:
                      RepositoryProvider.of<SearchUserRepository>(context)))
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              textTheme: const TextTheme(
                  bodyText2: TextStyle(fontSize: 33),
                  subtitle1: TextStyle(fontSize: 22))),
          home: const Scaffold(
            body: SafeArea(
              child: SearchPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final users = context.select((SearchBloc bloc) => bloc.state.users);
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text('Search'),
        Padding(
          padding: const EdgeInsets.all(14),
          child: TextFormField(
            decoration: InputDecoration(
                hintText: 'enter username',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            onChanged: (value) {
              context.read<SearchBloc>().add(SearchUserEvent(value));
            },
          ),
        ),
        if (users.isNotEmpty)
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(users[index].username ?? ''),
                leading: Hero(
                  tag: user.username ?? '',
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.images ?? ''),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => UserInfoScreen(
                                user: user,
                              )));
                },
              );
            },
            itemCount: users.length,
          ))
      ],
    );
  }
}

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({Key? key, required this.user}) : super(key: key);

  final UserModel user;

  launchUrl(url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.username ?? ''),
      ),
      body: Column(
        children: [
          Hero(
              tag: user.username ?? '',
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(user.images ?? ''))),
              )),
          Text.rich(TextSpan(style: const TextStyle(fontSize: 16), children: [
            const TextSpan(text: 'Visit site'),
            TextSpan(
                text: user.url ?? '',
                style: const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("Jumping")));
                    launchUrl(user.url ?? '');
                  })
          ]))
        ],
      ),
    );
  }
}
