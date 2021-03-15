import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Job extends Equatable {
  Job(
      {this.subList,
      @required this.id,
      @required this.name,
      @required this.ratePerHour});
  final String id;
  final String name;
  final int ratePerHour;
  final List<dynamic> subList;

  @override
  List<Object> get props => [id, name, ratePerHour, subList];

  @override
  bool get stringify => true;

  factory Job.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      throw StateError('missing data for jobId: $documentId');
    }
    final name = data['name'] as String;
    if (name == null) {
      throw StateError('missing name for jobId: $documentId');
    }
    final ratePerHour = data['ratePerHour'] as int;
    //final subList = data['subList'] as List;
    final subList = data['subList'].map((set) {
      return Set.fromMap(set);
    }).toList();
    return Job(
        id: documentId, name: name, ratePerHour: ratePerHour, subList: subList);
  }

  List<Map<String, dynamic>> firestoreSets() {
    List<Map<String, dynamic>> convertedSets = [];
    this.subList.forEach((set) {
      Set thisSet = set as Set;
      convertedSets.add(thisSet.toMap());
    });
    return convertedSets;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'ratePerHour': this.ratePerHour,
      'subList': firestoreSets(),
    };
  }
}

class Set {
  final String subListTitle;
  bool subListStatus;

  Set(this.subListTitle, this.subListStatus);

  Map<String, dynamic> toMap() =>
      {"subListTitle": this.subListTitle, "subListStatus": this.subListStatus};

  Set.fromMap(Map<dynamic, dynamic> map)
      : subListTitle = map["subListTitle"].toString(),
        subListStatus = map["subListStatus"];
}
