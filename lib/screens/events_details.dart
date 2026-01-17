import 'package:appwrite/models.dart';
import 'package:event_planning_app/constants/colors.dart';
import 'package:event_planning_app/container/format_date.dart';
import 'package:event_planning_app/model/database.dart';
import 'package:event_planning_app/model/flutterwave_payment.dart';
import 'package:event_planning_app/saved_data.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';

class EventDetails extends StatefulWidget {
  final Document data;
  const EventDetails({super.key, required this.data});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  bool isRSVPedEvent = false;
  late String id = '';
  late String userEmail;
  bool hasBoughtTicket = false;

  @override
  void initState() {
    id = SavedData.getUserId();
    isRSVPedEvent = isUserPresent(widget.data.data["participants"], id);
    hasBoughtTicket = userHasBoughtTicket(widget.data.data["ticketBuyers"], id);
    userEmail = SavedData.getUserEmail();
    super.initState();
  }

  bool isUserPresent(List<dynamic> participants, String userId) {
    return participants.contains(id);
  }

  bool userHasBoughtTicket(List<dynamic> data, String id) {
    return data.contains(id);
  }

  Future<void> _buyTicket() async {
    try {
      final updatedBuyers = List<String>.from(widget.data.data["participants"]);
      if (!updatedBuyers.contains(id)) {
        updatedBuyers.add(id);
      }

      await databases.updateDocument(
        collectionId: "680f78a600257deecdb7",
        documentId: widget.data.$id,
        data: {
          "participants": updatedBuyers,
        },
        databaseId: '68053eec00004f0b9da0',
      );

      if (mounted) {
        setState(() {
          hasBoughtTicket = true;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket purchased successfully!")),
      );
    } catch (e) {
      print("Error while buying ticket: $e");
    }
  }

  void _handlePayment() async {
    final response = await _makePayment(
      name: "User Name",
      email: userEmail,
      ticketPrice: widget.data.data["price"],
    );

    if (response != null && response.status == "successful") {
      _buyTicket();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed or cancelled.")),
      );
    }
  }

  Future<ChargeResponse?> _makePayment(
      {required String name,
      required String email,
      required String ticketPrice}) async {
    final Customer customer = Customer(
      name: name,
      email: userEmail,
    );

    final Flutterwave flutterwave = Flutterwave(
      publicKey: "FLWPUBK_TEST-85c194712bfb20b8b3da5e4c8a76250a-X",
      currency: "NGN",
      redirectUrl: "https://facebook.com",
      txRef: "TXREF-${DateTime.now().millisecondsSinceEpoch}",
      amount: ticketPrice,
      customer: customer,
      paymentOptions: "card, payattitude, barter, bank transfer",
      customization: Customization(title: "Buy Event Ticket"),
      isTestMode: true,
    );

    final ChargeResponse response = await flutterwave.charge(
      context,
    );
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
                child: Transform.flip(
                  origin: const Offset(0, 250),
                  flipY: true,
                  child: Image.network(
                    'https://fra.cloud.appwrite.io/v1/storage/buckets/680fb7b70018d4081a4f/files/${widget.data.data["image"]}/view?project=680531750026ba8d8313',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 25,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 29,
                    color: Colors.white,
                  )),
            ),
            Positioned(
              bottom: 45,
              left: 8,
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    " ${formatDate(widget.data.data["datetime"])}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(width: 40),
                  const Icon(Icons.access_time_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    " ${formatTime(widget.data.data["datetime"])}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 8,
              child: Row(children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 4),
                Text(
                  "${widget.data.data["location"]}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ]),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.data.data["name"],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                  ),
                  // Icon(
                  //   Icons.share,
                  // )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.data["description"],
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "${widget.data.data["participants"].length} people are attending this event.",
                style: const TextStyle(
                    color: kLavender,
                    fontWeight: FontWeight.w500,
                    fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                "Special Guests",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "${widget.data.data["guests"] == "" ? "None" : widget.data.data["guests"]}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sponsors",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "${widget.data.data["sponsors"] == "" ? "None" : widget.data.data["sponsor"]}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "More Info",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Event Type: ${widget.data.data["isInPerson"] == true ? "In Person" : "Virtual"}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Time:   ${formatTime(widget.data.data["datetime"])}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Location:${widget.data.data["location"] == "" ? "None" : widget.data.data["location"]}",
                style: const TextStyle(color: Colors.white, wordSpacing: 50),
              ),
              // ElevatedButton.icon(
              //     onPressed: () {},
              //     icon: Icon(Icons.map),
              //     label: Text("Open With Google Maps")),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: MaterialButton(
                  clipBehavior: Clip.hardEdge,
                  color: kLavender,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          amount: '${widget.data.data["price"]}',
                          email: userEmail,
                        ),
                      ),
                    );
                    print("User email: ${SavedData.getUserEmail()}");

                    if (result == 'payment_success') {
                      setState(() {
                        hasBoughtTicket = true;
                      });

                      await _buyTicket();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Payment successful! You can now RSVP.')),
                      );
                    }
                  },
                  child: Text(
                    widget.data.data["participants"]
                            .contains(SavedData.getUserId())
                        ? 'Attending Event'
                        : 'Pay ${widget.data.data["price"]} to RSVP',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        )
      ]),
    ));
  }
}
