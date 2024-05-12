import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class EditMemberPage extends StatefulWidget {
  const EditMemberPage({Key? key}) : super(key: key);

  @override
  _EditMemberPageState createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  final _dio = Dio();
  final _storage = GetStorage();
  final _apiUrl = 'https://mobileapis.manpits.xyz/api';

  Member? member;
  DateTime? _tglLahir;

  final TextEditingController noIndukController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController tglLahirController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  late int id = 0;

  int statusAktifValue = 1;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null) {
      id = args as int;
      detailMember();
    }
  }

  Future<void> detailMember() async {
    setState(() {
      isLoading = true;
    });

    try {
      final _response = await _dio.get(
        '$_apiUrl/anggota/$id',
        options: Options(
          headers: {'Authorization': 'Bearer ${_storage.read('token')}'},
        ),
      );

      if (_response.statusCode == 200) {
        final responseData = _response.data;
        final memberData = responseData['data']['anggota'];
        setState(() {
          member = Member.fromJson(memberData);
          if (member != null) {
            noIndukController.text = member?.nomorInduk?.toString() ?? '';
            namaController.text = member?.nama ?? '';
            alamatController.text = member?.alamat ?? '';
            teleponController.text = member?.telepon ?? '';
            statusAktifValue = member?.statusAktif ?? 1;
            _tglLahir = DateFormat("yyyy-MM-dd").parse(member?.tglLahir ?? '');
            tglLahirController.text =
                DateFormat("yyyy-MM-dd").format(_tglLahir!);
          }
        });
      } else {
        print('Terjadi kesalahan: ${_response.statusCode}');
      }
    } on DioError catch (e) {
      print('Terjadi kesalahan: ${e.message}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1B8989),
        title: Text(
          'Edit Member',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30),
              TextFormField(
                controller: noIndukController,
                decoration: InputDecoration(
                  labelText: "No Induk",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  suffixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  suffixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: alamatController,
                decoration: InputDecoration(
                  labelText: "Alamat",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  suffixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: tglLahirController,
                decoration: InputDecoration(
                  labelText: "Tanggal Lahir (YYYY-MM-DD)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      // _selectDate();
                    },
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: teleponController,
                decoration: InputDecoration(
                  labelText: "Telepon",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  suffixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text('Status Aktif: '),
                  Radio(
                    value: 1,
                    groupValue: statusAktifValue,
                    onChanged: (value) {
                      setState(() {
                        statusAktifValue = value as int;
                      });
                    },
                  ),
                  Text('Aktif'),
                  Radio(
                    value: 0,
                    groupValue: statusAktifValue,
                    onChanged: (value) {
                      setState(() {
                        statusAktifValue = value as int;
                      });
                    },
                  ),
                  Text('Non Aktif'),
                ],
              ),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () {
                    goEditMember();
                  },
                  color: Color(0xFF1B8989),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    "Update",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  void goEditMember() async {
    setState(() {
      isLoading = true;
    });
    try {
      final _response = await _dio.put(
        '$_apiUrl/anggota/$id',
        data: {
          'nomor_induk': noIndukController.text,
          'nama': namaController.text,
          'alamat': alamatController.text,
          'tgl_lahir': _tglLahir != null ? _tglLahir!.toString() : '',
          'telepon': teleponController.text,
          'status_aktif': statusAktifValue,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_storage.read('token')}',
          },
        ),
      );
      print(_response.data);
      if (_response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Member Successfully Updated!"),
              content: Text('Your member information has been updated.'),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/homepage',
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Terjadi kesalahan: ${_response.statusCode}');
      }
    } on DioError catch (e) {
      print('${e.response} - ${e.response?.statusCode}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sorry!"),
            content: Text(e.response?.data['message'] ?? 'An error occurred'),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/homepage',
                  );
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}

class Member {
  int? id;
  int? nomorInduk;
  String? nama;
  String? alamat;
  String? tglLahir;
  String? telepon;
  int? statusAktif;

  Member({
    this.id,
    this.nomorInduk,
    this.nama,
    this.alamat,
    this.tglLahir,
    this.telepon,
    this.statusAktif,
  });

  Member.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nomorInduk = json['nomor_induk'],
        nama = json['nama'],
        alamat = json['alamat'],
        tglLahir = json['tgl_lahir'],
        telepon = json['telepon'],
        statusAktif = json['status_aktif'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomor_induk': nomorInduk,
      'nama': nama,
      'alamat': alamat,
      'tgl_lahir': tglLahir,
      'telepon': telepon,
      'status_aktif': statusAktif,
    };
  }
}
