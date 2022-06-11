import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/hex_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isAPIcallProcess = false;
  bool hidePassword = true;
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  String? cliente;
  String? destino;
  String? fecha;
  String? nroboleto;
  String? origen;
  String? precio;
  String? idTicket;
  int itemCountAll = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: HexColor('#283B71'),
        body: ProgressHUD(
          inAsyncCall: isAPIcallProcess,
          opacity: 0.3,
          key: UniqueKey(),
          child: Form(
            key: globalFormKey,
            child: _registerUI(context),
          ),
        ),
      ),
    );
  }

  Widget _registerUI(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: FloatingActionButton(
        onPressed: () {
          // When the User clicks on the button, display a BottomSheet
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return showBottomSheetCreate(context, false, null);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Venta Tickets'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        // Reading Items form our Database Using the  Builder widget
        stream: db.collection('todos').orderBy("nroboleto").snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, int index) {
              itemCountAll = snapshot.data?.docs.length + 1;
              DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
              idTicket = documentSnapshot.id;
              return ListTile(
                title: Text(
                    'Boleto Nro ' + documentSnapshot['nroboleto'].toString()),
                subtitle: Text('Cliente: ' + documentSnapshot['cliente']),
                onTap: () {
                  // Here We Will Add The Update Feature and passed the value 'true' to the is update
                  // feature.
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return showBottomSheetInfo(
                          context, true, documentSnapshot);
                    },
                  );
                },
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () {
                    // Here We Will Add The Delete Feature
                    db.collection('todos').doc(documentSnapshot.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  showBottomSheetCreate(
      BuildContext context, bool isUpdate, DocumentSnapshot? documentSnapshot) {
    // Added the isUpdate argument to check if our item has been updated
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                // Used a ternary operator to check if isUpdate is true then display
                // Update Todo.
                labelText: 'Fecha',
                hintText: 'Ingrese la fecha DD-MM-YYYY',
              ),
              onChanged: (String _val) {
                // Storing the value of the text entered in the variable value.
                fecha = _val;
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  // Used a ternary operator to check if isUpdate is true then display
                  // Update Todo.
                  labelText: 'Origen',
                  hintText: 'Ingrese el lugar de origen',
                ),
                onChanged: (String _val) {
                  // Storing the value of the text entered in the variable value.
                  origen = _val;
                },
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  // Used a ternary operator to check if isUpdate is true then display
                  // Update Todo.
                  labelText: 'Destino ',
                  hintText: 'Ingrese el lugar de destino',
                ),
                onChanged: (String _val) {
                  // Storing the value of the text entered in the variable value.
                  destino = _val;
                },
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  // Used a ternary operator to check if isUpdate is true then display
                  // Update Todo.
                  labelText: 'Precio',
                  hintText: 'Ingrese el precio',
                ),
                onChanged: (String _val) {
                  // Storing the value of the text entered in the variable value.
                  precio = _val;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.lightBlueAccent),
                ),
                onPressed: () {
                  db.collection('todos').add({
                    'nroboleto': itemCountAll,
                    'cliente': 'Jose',
                    'fecha': fecha,
                    'origen': origen,
                    'destino': destino,
                    'precio': int.parse(precio!)
                  });
                  Navigator.pop(context);
                },
                child: const Text('Crear Boleto',
                    style: TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }

  showBottomSheetInfo(
      BuildContext context, bool isUpdate, DocumentSnapshot? documentSnapshot) {
    // Added the isUpdate argument to check if our item has been updated
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: FutureBuilder<DocumentSnapshot>(
        builder: ((context, snapshot) {
          //print(documentSnapshot!['nroboleto']);
          return Center(
            child: Card(
              child: Column(
                children: <Widget>[
                  // ignore: unnecessary_new
                  new Text(
                    "Nro Boleto: " + documentSnapshot!['nroboleto'].toString(),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  // ignore: prefer_const_constructors
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                  ),
                  const Divider(),
                  // ignore: unnecessary_new
                  new Text(
                    "Cliente: " + documentSnapshot['cliente'].toString(),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  // ignore: prefer_const_constructors
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                  ),
                  const Divider(),
                  // ignore: unnecessary_new
                  new Text(
                    "Fecha: " + documentSnapshot['fecha'].toString(),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  // ignore: prefer_const_constructors
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                  ),
                  Divider(),
                  // ignore: unnecessary_new
                  new Text(
                    "Precio: " + documentSnapshot['precio'].toString() + " Bs",
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  // ignore: prefer_const_constructors
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                  ),
                  Divider(),
                  // ignore: unnecessary_new
                  new Text(
                    "Origen: " + documentSnapshot['origen'].toString(),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  // ignore: prefer_const_constructors
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                  ),
                  const Divider(),
                  // ignore: unnecessary_new
                  new Text(
                    "Destino: " + documentSnapshot['destino'].toString(),
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  const Divider(),
                  Container(
                    width: 300.0,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
