import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/app/home/models/job.dart';
import 'package:starter_architecture_flutter_firebase/app/top_level_providers.dart';
import 'package:starter_architecture_flutter_firebase/routing/app_router.dart';
import 'package:starter_architecture_flutter_firebase/services/firestore_database.dart';

class EditJobPage extends StatefulWidget {
  const EditJobPage({Key key, this.job}) : super(key: key);
  final Job job;

  static Future<void> show(BuildContext context, {Job job}) async {
    await Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.editJobPage,
      arguments: job,
    );
  }

  @override
  _EditJobPageState createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  int _ratePerHour;
  List<dynamic> _subList = [];
  Set newSet = Set('', false);

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _name = widget.job?.name;
      _ratePerHour = widget.job?.ratePerHour;
      _subList = widget.job?.subList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.job == null ? 'New Job' : 'Edit Job'),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            onPressed: () => _submit(),
          ),
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildFormChildren(),
      ),
    );
  }

  List<Widget> _buildFormChildren() {
    print(_subList);
    return [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Job name'),
        keyboardAppearance: Brightness.light,
        initialValue: _name,
        validator: (value) =>
            (value ?? '').isNotEmpty ? null : 'Name can\'t be empty',
        onChanged: (value) {
          setState(() {
            _name = value;
          });
        },
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Rate per hour'),
        keyboardAppearance: Brightness.light,
        initialValue: _ratePerHour != null ? '$_ratePerHour' : null,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        onChanged: (value) {
          setState(() {
            _ratePerHour = int.tryParse(value ?? '') ?? 0;
          });
        },
      ),
      Column(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            itemCount: _subList?.length ?? 0,
            itemBuilder: (context, index) {
              String initialValueTextFormField =
                  _subList[index].subListTitle.toString();
              bool initialValueCheckbox = _subList[index].subListStatus;
              return Row(
                children: [
                  Checkbox(
                    value: initialValueCheckbox,
                    onChanged: (bool newValue) {
                      setState(
                        () {
                          initialValueCheckbox = newValue;
                          _subList.removeAt(index);
                          _subList.insert(
                              index,
                              Set(initialValueTextFormField,
                                  initialValueCheckbox));
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      minLines: 1,
                      maxLines: 1,
                      initialValue: initialValueTextFormField,
                      autofocus: false,
                      textAlign: TextAlign.left,
                      onChanged: (title) {
                        setState(() {
                          initialValueTextFormField = title;
                          _subList.removeAt(index);
                          _subList.insert(
                              index,
                              Set(initialValueTextFormField,
                                  initialValueCheckbox));
                        });
                      },
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        hintText: 'Write sub List here',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _subList.add(newSet);
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add),
                Text('Add Sub Lists'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  void _submit() {
    final isValid = _formKey.currentState.validate();

    if (!isValid) {
      return;
    } else {
      final database = context.read<FirestoreDatabase>(databaseProvider);
      final id = widget.job?.id ?? documentIdFromCurrentDate();
      final job = Job(
          id: id,
          name: _name ?? '',
          ratePerHour: _ratePerHour ?? 0,
          subList: _subList);
      database.setJob(job);
      Navigator.of(context).pop();
    }
  }
}
