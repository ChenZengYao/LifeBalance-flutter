import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_helpers/firebase_helpers.dart';
import 'package:lifebalance/screens/event.dart';

  DatabaseService<EventModel> eventDBS = DatabaseService<EventModel>("events",fromDS: (id,data) => EventModel.fromDS(id, data), toMap:(event) => event.toMap());