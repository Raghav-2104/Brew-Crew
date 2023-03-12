import 'package:brew_crew/Models/user.dart';
import 'package:brew_crew/Services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4', '5'];

  late String _currentName;
  String _currentSugars = '0';
  int _currentStrength = 100;

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseSerive(uid: user!.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;
            return Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Update your brew settings.',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: userData!.name,
                      decoration: textDecoration.copyWith(hintText: 'Name'),
                      validator: (val) =>
                          val!.isEmpty ? 'Please enter a name' : null,
                      onChanged: (val) => setState(() => _currentName = val),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    DropdownButtonFormField(
                      value: _currentSugars ?? userData!.sugars,
                      items: sugars.map((sugar) {
                        return DropdownMenuItem(
                          value: sugar,
                          child: Text("$sugar sugars"),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _currentSugars = val!),
                    ),
                    Slider(
                      value: (_currentStrength ?? 100).toDouble(),
                      activeColor: Colors.brown[_currentStrength ?? userData!.strength],
                      inactiveColor: Colors.brown[_currentStrength ?? userData!.strength],
                      min: 100.0,
                      max: 900.0,
                      divisions: 8,
                      onChanged: (val) =>
                          setState(() => _currentStrength = val.round()),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[400],
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await DatabaseSerive(uid: user.uid).updateUserData(
                                _currentSugars ?? snapshot.data!.sugars,
                                _currentName ?? snapshot.data!.name,
                                _currentStrength ?? snapshot.data!.strength);
                            Navigator.pop(context);
                          }
                        }),
                  ],
                ));
          } else {
            return Loading();
          }
        });
  }
}
