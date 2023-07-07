// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mkulimadriver/models/schedule.dart';
import 'package:mkulimadriver/models/user.dart';
import 'package:mkulimadriver/services/schedule_services.dart';
import 'package:mkulimadriver/theme/colors.dart';
import 'package:mkulimadriver/widgets/app_date_picker.dart';
import 'package:mkulimadriver/widgets/app_elevated_button.dart';
import 'package:mkulimadriver/widgets/app_textformfield.dart';
import 'package:mkulimadriver/widgets/pop_up_dialogs.dart';

class ScheduleJourneyPage extends StatefulWidget {
  final User user;
  final DriverSchedule? schedule;
  ScheduleJourneyPage({this.schedule, required this.user});

  @override
  State<ScheduleJourneyPage> createState() => _ScheduleJourneyPageState();
}

class _ScheduleJourneyPageState extends State<ScheduleJourneyPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController start = TextEditingController();
  TextEditingController via = TextEditingController();
  TextEditingController destination = TextEditingController();
  TextEditingController space = TextEditingController();
  String dateError = "";
  String timeError = "";
  String startError = "";
  String viaError = "";
  String destinationError = "";
  String spaceError = "";

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      date.text = widget.schedule!.date!.substring(0, 10);
      time.text = widget.schedule!.date!.substring(11, 16);
      start.text = "${widget.schedule!.start}";
      destination.text = "${widget.schedule!.destination}";
      via.text = "${widget.schedule!.via}";
      space.text = "${widget.schedule!.space}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.gray,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(CupertinoIcons.chevron_back, color: colors.primary),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Schedule Your Journey",
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SizedBox(
          height: size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 50),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * .03),
              alignment: Alignment.center,
              child: Container(
                width: size.width,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * .03, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.gray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppTextFormField(
                            width: size.width * .4,
                            controller: date,
                            hintText: "Date of Departure",
                            color: colors.background,
                            errorText: dateError,
                            readOnly: true,
                            onTap: () {
                              _showDatePicker();
                            },
                            validator: (value) {
                              setState(() {
                                if (date.text.isNotEmpty) {
                                  dateError = "";
                                } else {
                                  dateError = "this field can not be empty";
                                }
                              });
                              return;
                            },
                          ),
                          AppTextFormField(
                            width: size.width * .4,
                            controller: time,
                            hintText: "Time of Departure",
                            color: colors.background,
                            errorText: timeError,
                            readOnly: true,
                            onTap: () {
                              _showTimePicker();
                            },
                            validator: (value) {
                              setState(() {
                                if (time.text.isNotEmpty) {
                                  timeError = "";
                                } else {
                                  timeError = "this field can not be empty";
                                }
                              });
                              return;
                            },
                          ),
                        ],
                      ),
                      AppTextFormField(
                        controller: start,
                        hintText: "Departure Location",
                        color: colors.background,
                        errorText: startError,
                        validator: (value) {
                          setState(() {
                            if (start.text.isNotEmpty) {
                              startError = "";
                            } else {
                              startError = "this field can not be empty";
                            }
                          });
                          return;
                        },
                      ),
                      AppTextFormField(
                        controller: destination,
                        hintText: "Destination",
                        color: colors.background,
                        errorText: destinationError,
                        validator: (value) {
                          setState(() {
                            if (destination.text.isNotEmpty) {
                              destinationError = "";
                            } else {
                              destinationError = "this field can not be empty";
                            }
                          });
                          return;
                        },
                      ),
                      AppTextFormField(
                        controller: via,
                        hintText: "Via",
                        color: colors.background,
                        errorText: viaError,
                        validator: (value) {
                          setState(() {
                            if (via.text.isNotEmpty) {
                              viaError = "";
                            } else {
                              viaError = "this field can not be empty";
                            }
                          });
                          return;
                        },
                      ),
                      AppTextFormField(
                        controller: space,
                        hintText: "Truck space",
                        color: colors.background,
                        errorText: spaceError,
                        validator: (value) {
                          setState(() {
                            if (space.text.isNotEmpty) {
                              spaceError = "";
                            } else {
                              spaceError = "this field can not be empty";
                            }
                          });
                          return;
                        },
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? CircularProgressIndicator()
                          : AppElevatedButton(
                              label:
                                  widget.schedule != null ? "Update" : "Save",
                              onPressed: validateInputs,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  validateInputs() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      if (dateError == "" &&
          startError == "" &&
          destinationError == "" &&
          spaceError == "" &&
          viaError == "" &&
          timeError == "") {
        saveSchedule();
      }
    }
  }

  saveSchedule() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> scheduleData = {
      "driver_id": widget.user.id,
      "date": "${date.text} ${time.text}",
      "destination": destination.text,
      "space": space.text,
      "start": start.text,
      "status": "active",
      "via": via.text,
      "phone": widget.user.phone,
    };

    try {
      var results;
      if (widget.schedule != null) {
        scheduleData['id'] = widget.schedule!.id;
        results =
            await scheduleServices.updateSchedule(scheduleData: scheduleData);
      } else {
        results =
            await scheduleServices.saveSchedule(scheduleData: scheduleData);
      }
      if (results is DriverSchedule) {
        Navigator.pop(context);
      } else {
        dialog.errorDialog(
          context: context,
          header: "ERROR!",
          body: "$results",
        );
      }
    } catch (e) {
      print("--------------------------------------------------------$e");
      dialog.errorDialog(
        context: context,
        header: "ERROR!",
        body:
            "Registration returned errors, Please check your connection and retry",
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  _showDatePicker() async {
    setState(() {
      date.text =
          DateTime.now().add(Duration(days: 7)).toString().substring(0, 10);
    });

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(days: 7)),
        firstDate: DateTime.now().add(Duration(days: 7)),
        lastDate: DateTime(DateTime.now().year + 1));
    if (picked != null && picked.toString().substring(0, 10) != date)
      setState(() {
        date.text = picked.toString().substring(0, 10);
      });
  }

  _showTimePicker() async {
    setState(() {
      time.text = "${TimeOfDay.now().hour}:${TimeOfDay.now().minute}";
    });

    final TimeOfDay? picked = await showTimePicker(
      helpText: "Select departure time",
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null)
      setState(() {
        time.text = "${picked.hour}:${picked.minute}";
      });
  }
}
