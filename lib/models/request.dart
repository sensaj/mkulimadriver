import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mkulimadriver/services/helper_services.dart';

class ClientRequest {
  String? id;
  String? destination;
  String? parcel;
  String? sender;
  String? receiver;
  String? start;
  String? schedule;
  LatLng? senderPosition;
  LatLng? receiverPosition;

  ClientRequest({
    this.destination,
    this.id,
    this.parcel,
    this.receiver,
    this.schedule,
    this.sender,
    this.start,
    this.receiverPosition,
    this.senderPosition,
  });

  factory ClientRequest.fromMap(Map<String, dynamic> map) {
    return ClientRequest(
      id: map['id'],
      parcel: map['parcel'],
      start: map['start'],
      receiver: map['receiver_id'],
      sender: map['client_id'],
      destination: map['destination'],
      schedule: map['schedule_id'],
      senderPosition: helper.locStrToLatLng(position: map['sender_position']),
      receiverPosition:
          helper.locStrToLatLng(position: map['receiver_position']),
    );
  }

  factory ClientRequest.fromJson(Map<String, dynamic> json) {
    return ClientRequest(
      id: json['id'],
      parcel: json['parcel'],
      start: json['start'],
      sender: json['client_id'],
      receiver: json['receiver_id'],
      destination: json['destination'],
      schedule: json['schedule_id'],
      senderPosition: helper.locStrToLatLng(position: json['sender_position']),
      receiverPosition:
          helper.locStrToLatLng(position: json['receiver_position']),
    );
  }
}
