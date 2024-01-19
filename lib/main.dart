import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unihelp/firebase_options.dart';
import 'package:unihelp/typesWork.dart';
import 'package:unihelp/bloc/api_bloc.dart';
import 'package:unihelp/bloc/api_events.dart';
import 'package:unihelp/bloc/api_states.dart';
import 'package:unihelp/dialogues.dart';
import 'package:unihelp/disciplines.dart';
import 'package:unihelp/search.dart';
import 'package:unihelp/profile.dart';
import 'package:unihelp/start.dart';
import 'package:unihelp/unis.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => ApiBloc(), // Create an instance of ApiBloc
        child: const MyHomePage(), // Set MyHomePage as the home screen
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ApiBloc>(context)
        .add(SearchEvent()); // Dispatch an event to fetch the list of notes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[300],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Dialogues',
          ),
        ],
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            BlocProvider.of<ApiBloc>(context).add(SearchEvent());
          } else if (index == 1) {
            BlocProvider.of<ApiBloc>(context).add(ProfileEvent());
          } else if (index == 2) {
            BlocProvider.of<ApiBloc>(context).add(DialogEvent());
          }
        },
        currentIndex: _selectedIndex,
      ),
      body: buildBloc(), // Build the UI based on the current state
    );
  }

  Widget buildBloc() {
    return BlocBuilder<ApiBloc, ApiStates>(builder: (context, state) {
      print(state);
      if (state is LoadingState) {
        return const Center(
          child: CircularProgressIndicator(),
        ); // Show a loading indicator while fetching data// Show the note details screen
      } else if (state is ErrorState) {
        return const Center(
          child: Text("Error"),
        ); // Show an error message if there's an error state
      } else if (state is SearchState) {
        return const SearchPage();
      } else if (state is DialogState) {
        return const DialoguePage();
      } else if (state is ProfileState) {
        return const ProfilePage();
      } else if (state is UnisState) {
        return UnisPage(unis: state.unis);
      } else if (state is DisciplinesState) {
        return const DisciplinesPage();
      } else if (state is TypesState) {
        return const TypesPage();
      } else if (state is StartState) {
        return const StartPage();
      } else {
        return const Text(
          "Nothing",
        ); // Show a default message if the state is not recognized
      }
    });
  }
}
