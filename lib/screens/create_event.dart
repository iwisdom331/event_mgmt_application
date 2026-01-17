import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:event_planning_app/appwrite.dart';
import 'package:event_planning_app/constants/colors.dart';
import 'package:event_planning_app/container/custom_headertext.dart';
import 'package:event_planning_app/container/custom_input_form.dart';
import 'package:event_planning_app/model/database.dart';
import 'package:event_planning_app/saved_data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  FilePickerResult? _filePickerResult;
  bool _isinPersonEvent = true;

  Storage storage = Storage(client);
  bool isUploading = false;
  String userId = "";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _guestController = TextEditingController();
  final TextEditingController _sponsorsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    userId = SavedData.getUserId();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2200));

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDateTime.year,
          pickedDateTime.month,
          pickedDateTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _dateTimeController.text = selectedDateTime.toString();
        });
        print(selectedDateTime);
      }
    }
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    setState(() {
      _filePickerResult = result;
    });
  }

  Future uploadEventImage() async {
    setState(() {
      isUploading = true;
    });
    try {
      if (_filePickerResult != null) {
        PlatformFile file = _filePickerResult!.files.first;
        final fileByte = await File(file.path!).readAsBytes();
        final inputFile =
            InputFile.fromBytes(bytes: fileByte, filename: file.name);

        final response = await storage.createFile(
            bucketId: "680fb7b70018d4081a4f",
            fileId: ID.unique(),
            file: inputFile);
        print(response.$id);
        return (response.$id);
      } else {
        print("Something went wrong");
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 60),
                height: 50,
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 10),
                    CustomHeadText(text: 'Create Event'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _openFilePicker(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: kLavender.withOpacity(.8),
                  ),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .3,
                  child: _filePickerResult != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image(
                            image: FileImage(
                              File(_filePickerResult!.files.first.path!),
                            ),
                            fit: BoxFit.fill,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 42,
                              color: Colors.black,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Add Event Image",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              CustomInputForm(
                controller: _nameController,
                icon: Icons.event_outlined,
                label: 'Event Name',
                hint: 'Enter Event Name',
              ),
              const SizedBox(height: 8),
              CustomInputForm(
                maxLines: 4,
                controller: _descController,
                icon: Icons.description_outlined,
                label: 'Description',
                hint: 'Add description',
              ),
              const SizedBox(height: 8),
              CustomInputForm(
                controller: _locationController,
                icon: Icons.location_on_outlined,
                label: 'Location',
                hint: 'Enter Location of Event',
              ),
              const SizedBox(height: 8),
              CustomInputForm(
                controller: _guestController,
                icon: Icons.people_outlined,
                label: 'Guests',
                hint: 'Enter list of guests',
              ),
              const SizedBox(height: 8),
              CustomInputForm(
                controller: _priceController,
                icon: Icons.money_outlined,
                label: 'Price',
                hint: 'Enter price for the event',
              ),
              const SizedBox(height: 8),
              CustomInputForm(
                readOnly: true,
                controller: _dateTimeController,
                icon: Icons.date_range_outlined,
                label: 'Date & Time',
                hint: 'Pick Date of the Event',
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 8),
              CustomInputForm(
                controller: _sponsorsController,
                icon: Icons.attach_money_outlined,
                label: 'Sponsors',
                hint: 'Enter Sponsors of Event',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'In Person Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    activeThumbColor: kLavender,
                    focusColor: Colors.purpleAccent,
                    value: _isinPersonEvent,
                    onChanged: (value) {
                      setState(() {
                        _isinPersonEvent = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: MaterialButton(
                  clipBehavior: Clip.hardEdge,
                  color: kLavender,
                  onPressed: () {
                    if (_nameController.text == "" ||
                        _descController.text == "" ||
                        _dateTimeController.text == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Event Name, Description, Date and time must be filled out"),
                        ),
                      );
                      return;
                    } else {
                      uploadEventImage()
                          .then((value) => createEvent(
                                _nameController.text,
                                _descController.text,
                                value,
                                _locationController.text,
                                _dateTimeController.text,
                                userId,
                                _isinPersonEvent,
                                _guestController.text,
                                _sponsorsController.text,
                                _priceController.text,
                              ))
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Event Created")));
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: const Text(
                    'Create New Event',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
