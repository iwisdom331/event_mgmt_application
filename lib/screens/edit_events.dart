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

class EditEventPage extends StatefulWidget {
  final String image, name, desc, loc, guests, price, datetime, sponsors, docID;
  final bool isInPerson;
  const EditEventPage(
      {super.key,
      required this.image,
      required this.name,
      required this.desc,
      required this.loc,
      required this.guests,
      required this.price,
      required this.datetime,
      required this.sponsors,
      required this.docID,
      required this.isInPerson});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage>
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
    _nameController.text = widget.name;
    _descController.text = widget.desc;
    _locationController.text = widget.loc;
    _dateTimeController.text = widget.datetime;
    _guestController.text = widget.guests;
    _sponsorsController.text = widget.sponsors;
    _priceController.text = widget.price;
    _isinPersonEvent = widget.isInPerson;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
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
                      CustomHeadText(text: 'Edit Event'),
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
                                  File(_filePickerResult!.files.first.path!)),
                              fit: BoxFit.fill,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://fra.cloud.appwrite.io/v1/storage/buckets/680fb7b70018d4081a4f/files/${widget.image}/view?project=680531750026ba8d8313',
                              fit: BoxFit.fill,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomInputForm(
                    controller: _nameController,
                    icon: Icons.event_outlined,
                    label: 'Event Name',
                    hint: 'Enter Event Name'),
                const SizedBox(height: 8),
                CustomInputForm(
                    maxLines: 4,
                    controller: _descController,
                    icon: Icons.description_outlined,
                    label: 'Description',
                    hint: 'Add description'),
                const SizedBox(height: 8),
                CustomInputForm(
                    controller: _locationController,
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    hint: 'Enter Location of Event'),
                const SizedBox(height: 8),
                CustomInputForm(
                    controller: _guestController,
                    icon: Icons.people_outlined,
                    label: 'Guests',
                    hint: 'Enter list of guests'),
                const SizedBox(height: 8),
                CustomInputForm(
                    controller: _priceController,
                    icon: Icons.money_outlined,
                    label: 'Price',
                    hint: 'Enter price for the event'),
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
                    hint: 'Enter Sponsors of Event'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'In Person Event',
                      style: TextStyle(
                        color: kLavender,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      activeThumbColor: kLavender,
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
                      }

                      if (_filePickerResult == null) {
                        updateEvent(
                          _nameController.text,
                          _descController.text,
                          widget.image,
                          _locationController.text,
                          _dateTimeController.text,
                          userId,
                          _isinPersonEvent,
                          _guestController.text,
                          _sponsorsController.text,
                          _priceController.text,
                          widget.docID,
                        ).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Event Updated")),
                          );
                          Navigator.pop(context);
                        });
                      } else {
                        uploadEventImage().then((value) {
                          updateEvent(
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
                            widget.docID,
                          ).then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Event Updated")),
                            );
                            Navigator.pop(context);
                          });
                        });
                      }
                    },
                    child: const Text(
                      'Update Event',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Danger Zone",
                  style: TextStyle(
                    color: Color.fromARGB(255, 248, 107, 97),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MaterialButton(
                    color: const Color.fromARGB(255, 248, 107, 97),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text(
                            "Are you sure?",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            "Your event will be deleted",
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                await deleteEvent(widget.docID);
                                await storage.deleteFile(
                                  bucketId: "680fb7b70018d4081a4f",
                                  fileId: widget.image,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Event Deleted Successfully")),
                                );
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text("Yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("No"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Delete Event',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
