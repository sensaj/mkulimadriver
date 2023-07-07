import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mkulimadriver/models/schedule.dart';

class ScheduleServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DriverSchedule?> saveSchedule(
      {required Map<String, dynamic> scheduleData}) async {
    DriverSchedule? schedule;
    DocumentReference scheduleDoc = _firestore.collection('schedules').doc();
    try {
      await scheduleDoc.set(scheduleData);
      schedule = DriverSchedule.fromMap(scheduleData);
      return schedule;
    } catch (error) {
      print('======================>Failed to write data: $error');
      return schedule;
    }
  }

  Future<DriverSchedule?> updateSchedule(
      {required Map<String, dynamic> scheduleData}) async {
    print("hahahhahahhahahha");
    DriverSchedule? schedule;

    try {
      DocumentReference scheduleDoc = FirebaseFirestore.instance
          .collection('schedules')
          .doc(scheduleData['id']);
      await scheduleDoc.update(scheduleData);
      schedule = DriverSchedule.fromMap(scheduleData);
      return schedule;
    } catch (error) {
      print('======================>Failed to write data: $error');
      return schedule;
    }
  }
}

ScheduleServices scheduleServices = ScheduleServices();
