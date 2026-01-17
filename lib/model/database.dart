import 'package:appwrite/appwrite.dart';
import 'package:event_planning_app/appwrite.dart';
import 'package:event_planning_app/saved_data.dart';

String databaseId = '68053eec00004f0b9da0';

final Databases databases = Databases(client);
String chatsCollectionId = '682915f400139d4af283';
String messagesCollectionId = '6829f399003b88570a08';
String eventCollectionId = "680f78a600257deecdb7";

Future<void> saveUserData(String name, String email, String userId, String role,
    String profileImage) async {
  return await databases
      .createDocument(
          databaseId: databaseId,
          collectionId: '68053ef6000aac4ae43b',
          documentId: ID.unique(),
          data: {
            "name": name,
            "email": email,
            "userId": userId,
            "profileImage": profileImage,
          })
      .then((value) => print('Document created'))
      .catchError((e) => print(e));
}

Future getUserData() async {
  final id = SavedData.getUserId();
  try {
    final data = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: '68053ef6000aac4ae43b',
        queries: [Query.equal('userId', id)]);

    SavedData.saveUsername(data.documents[0].data["name"]);
    SavedData.saveUserEmail(data.documents[0].data["email"]);
    print(data);
  } catch (e) {
    print(e);
  }
}

Future<void> createEvent(
  String name,
  String desc,
  String image,
  String location,
  String datetime,
  String createdBy,
  bool isInPersonOrNot,
  String guest,
  String sponsors,
  String price,
) async {
  return await databases
      .createDocument(
          databaseId: databaseId,
          collectionId: "680f78a600257deecdb7",
          documentId: ID.unique(),
          data: {
            'name': name,
            'description': desc,
            'image': image,
            'location': location,
            'datetime': datetime,
            'createdBy': createdBy,
            'isInPerson': isInPersonOrNot,
            'guests': guest,
            'sponsors': sponsors,
            'price': price,
          })
      .then((value) => print("Event Created"))
      .catchError((e) => print(e));
}

Future getAllEvents() async {
  try {
    final data = await databases.listDocuments(
        databaseId: databaseId, collectionId: "680f78a600257deecdb7");
    return data.documents;
  } catch (e) {
    print(e);
  }
}

Future rsvpEvent(List participants, String documentId) async {
  final userId = SavedData.getUserId();
  participants.add(userId);
  try {
    await databases.updateDocument(
        databaseId: databaseId,
        collectionId: "680f78a600257deecdb7",
        documentId: documentId,
        data: {"participants": participants});
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

Future manageEvents() async {
  final userId = SavedData.getUserId();
  try {
    final data = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        queries: [Query.equal("createdBy", userId)]);
    return data.documents;
  } catch (e) {
    print(e);
  }
}

//
Future<void> updateEvent(
    String name,
    String desc,
    String image,
    String location,
    String datetime,
    String createdBy,
    bool isInPersonOrNot,
    String guest,
    String sponsors,
    String price,
    String docID) async {
  return await databases
      .updateDocument(
          databaseId: databaseId,
          collectionId: "680f78a600257deecdb7",
          documentId: docID,
          data: {
            'name': name,
            'description': desc,
            'image': image,
            'location': location,
            'datetime': datetime,
            'createdBy': createdBy,
            'isInPerson': isInPersonOrNot,
            'guests': guest,
            'sponsors': sponsors,
            'price': price,
          })
      .then((value) => print("Event Updated"))
      .catchError((e) => print(e));
}

Future deleteEvent(String docID) async {
  try {
    final response = await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: "680f78a600257deecdb7",
        documentId: docID);
    print(response);
  } catch (e) {
    print(e);
  }
}

Future getUpcomingEvents() async {
  try {
    final now = DateTime.now();
    final response = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: "64bb726399a1320b557f",
      queries: [
        Query.greaterThan("datetime", now),
      ],
    );

    return response.documents;
  } catch (e) {
    print(e);
    return [];
  }
}

Future getPastEvents() async {
  try {
    final now = DateTime.now();
    final response = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: eventCollectionId,
      queries: [
        Query.lessThan("datetime", now),
      ],
    );

    return response.documents;
  } catch (e) {
    print(e);
    return [];
  }
}

Future<String?> getOrCreateChat(List<String> participantIds) async {
  try {
    participantIds.sort();
    final existing = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: chatsCollectionId,
      queries: [
        Query.equal('participants', participantIds),
      ],
    );

    if (existing.documents.isNotEmpty) {
      return existing.documents.first.$id;
    }
    final newId = ID.unique();
    final chat = await databases.createDocument(
      databaseId: databaseId,
      collectionId: chatsCollectionId,
      documentId: newId,
      data: {
        'chatId': newId,
        'participants': participantIds,
        'lastMessage': '',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
    );

    print('Chat room created');
    return chat.$id;
  } catch (e) {
    print('Error getting or creating chat room: $e');
    return null;
  }
}

Future<List> getUserChats(String userId) async {
  try {
    final res = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: chatsCollectionId,
      queries: [
        Query.contains('participants', userId),
        Query.orderDesc('lastUpdated')
      ],
    );
    return res.documents;
  } catch (e) {
    print('Error fetching user chats: $e');
    return [];
  }
}

Future<void> sendMessageToUser(
  String chatId,
  String timestamp, {
  required String senderId,
  required String receiverId,
  required String message,
}) async {
  final timestamp = DateTime.now().toIso8601String();
  final chatId = await getOrCreateChat([senderId, receiverId]);

  if (chatId == null) {
    print('Failed to get or create chat room');
    return;
  }

  try {
    await databases.createDocument(
      databaseId: databaseId,
      collectionId: messagesCollectionId,
      documentId: ID.unique(),
      data: {
        'chatId': chatId,
        'senderId': senderId,
        'message': message,
        'timestamp': timestamp,
      },
    );

    await databases.updateDocument(
      databaseId: databaseId,
      collectionId: chatsCollectionId,
      documentId: chatId,
      data: {
        'lastMessage': message,
        'lastUpdated': timestamp,
      },
    );

    print('Message sent');
  } catch (e) {
    print('Error sending message: $e');
  }
}

Future<List> getMessagesForChat(String chatId) async {
  try {
    final res = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: messagesCollectionId,
      queries: [
        Query.equal('chatId', chatId),
        Query.orderAsc('timestamp'),
      ],
    );
    return res.documents;
  } catch (e) {
    print('Error fetching messages: $e');
    return [];
  }
}




//Future<void> updateEvent(
//     String name,
//     String desc,
//     String image,
//     String location,
//     String datetime,
//     String createdBy,
//     bool isInPersonOrNot,
//     String guest,
//     String sponsors,
//     String price,
//     String docID) async {
//   return await databases
//       .updateDocument(
//           databaseId: databaseId,
//           collectionId: eventCollectionId,
//           documentId: docID,
//           data: {
//             "name": name,
//             "description": desc,
//             "image": image,
//             "location": location,
//             "datetime": datetime,
//             "createdBy": createdBy,
//             "isInPerson": isInPersonOrNot,
//             "guests": guest,
//             "sponsors": sponsors,
//             "price": price,
//           })
//       .then((value) => print("Event Updated"))
//       .catchError((e) => print(e));
// }

// Future deleteEvent(String docID) async {
//   try {
//     final response = await databases.deleteDocument(
//         databaseId: databaseId,
//         collectionId: eventCollectionId,
//         documentId: docID);

//     print(response);
//   } catch (e) {
//     print(e);
//   }
// }