import 'package:flutter/material.dart';
import 'package:pl2_kasir/services/crud_service.dart';
import 'package:pl2_kasir/wigdet/list_wigdet.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _pegawaiFormKey =
      GlobalKey<FormState>(); // unutk validasi imput sebelum data dikirim
  final _pegawaiUsernameController = TextEditingController();
  final _pegawaiPasswordController = TextEditingController();
  final _pelangganFormKey = GlobalKey<FormState>();
  final _pelangganNamaController = TextEditingController();
  final _pelangganAlamatController = TextEditingController();
  final _pelangganNoTelpController = TextEditingController();

  List<Map<String, dynamic>> _pegawaiList = []; //unutk menyimpan data yg dkirim(pegawai/pelanggan)
  List<Map<String, dynamic>> _pelangganList = [];
  bool _isLoading = false;
  bool _isPegawaiEditing = false;
  bool _isPelangganEditing = false;
  int? _editingPegawaiId;
  int? _editingPelangganId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pegawaiUsernameController.dispose();
    _pegawaiPasswordController.dispose();
    _pelangganNamaController.dispose();
    _pelangganAlamatController.dispose();
    _pelangganNoTelpController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final pegawaiData = await CrudServices.loadPegawai();
      final pelangganData = await CrudServices.loadPelanggan();
      if (mounted) {
        setState(() {
          _pegawaiList = pegawaiData;
          _pelangganList = pelangganData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePegawaiAdd() async {
    try {
      await CrudServices.addPegawai(
        _pegawaiUsernameController.text,
        _pegawaiPasswordController.text,
      );
      if (mounted) {
        _resetPegawaiForm();
        await _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handlePelangganAdd() async {
    try {
      await CrudServices.addPelanggan(
        _pelangganNamaController.text,
        _pelangganAlamatController.text,
        _pelangganNoTelpController.text,
      );
      if (mounted) {
        _resetPelangganForm();
        await _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _resetPegawaiForm() {
    setState(() {
      _isPegawaiEditing = false;
      _editingPegawaiId = null;
      _pegawaiUsernameController.clear();
      _pegawaiPasswordController.clear();
    });
  }

  void _resetPelangganForm() {
    setState(() {
      _isPelangganEditing = false;
      _editingPelangganId = null;
      _pelangganNamaController.clear();
      _pelangganAlamatController.clear();
      _pelangganNoTelpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pegawai'), Tab(text: 'Pelanggan')],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                PegawaiList(
                  pegawaiList: _pegawaiList,
                  formKey: _pegawaiFormKey,
                  usernameController: _pegawaiUsernameController,
                  passwordController: _pegawaiPasswordController,
                  isEditing: _isPegawaiEditing,
                  editingId: _editingPegawaiId,
                  onAdd: () async {
                    if (_pegawaiFormKey.currentState!.validate()) {
                      await _handlePegawaiAdd();
                    }
                  },
                  onStartEdit: (pegawai) async {
                    setState(() {
                      _isPegawaiEditing = true;
                      _editingPegawaiId = pegawai['userid'];
                      _pegawaiUsernameController.text = pegawai['username'];
                      _pegawaiPasswordController.clear();
                    });
                  },
                  onDelete: (id) async {
                    try {
                      await CrudServices.deletePegawai(id);
                      await _loadInitialData();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  onUpdate: (id, username, password) async {
                    try {
                      await CrudServices.updatePegawai(id, username, password);
                      _resetPegawaiForm();
                      await _loadInitialData();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  onCancelEdit: _resetPegawaiForm,
                ),
                PelangganList(
                  pelangganList: _pelangganList,
                  formKey: _pelangganFormKey,
                  namaController: _pelangganNamaController,
                  alamatController: _pelangganAlamatController,
                  noTelpController: _pelangganNoTelpController,
                  isEditing: _isPelangganEditing,
                  editingId: _editingPelangganId,
                  onAdd: () async {
                    if (_pelangganFormKey.currentState!.validate()) {
                      await _handlePelangganAdd();
                    }
                  },
                  onStartEdit: (pelanggan) async {
                    setState(() {
                      _isPelangganEditing = true;
                      _editingPelangganId = pelanggan['pelangganid'];
                      _pelangganNamaController.text = pelanggan['nama'];
                      _pelangganAlamatController.text = pelanggan['alamat'];
                      _pelangganNoTelpController.text = pelanggan['no_tlp'];
                    });
                  },
                  onDelete: (id) async {
                    try {
                      await CrudServices.deletePelanggan(id);
                      await _loadInitialData();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  onUpdate: (id, nama, alamat, noTelp) async {
                    try {
                      await CrudServices.updatePelanggan(
                          id, nama, alamat, noTelp);
                      _resetPelangganForm();
                      await _loadInitialData();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  onCancelEdit: _resetPelangganForm,
                ),
              ],
            ),
    );
  }
}
