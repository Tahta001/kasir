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
  final _pegawaiFormKey = GlobalKey<FormState>();
  final _pegawaiUsernameController = TextEditingController();
  final _pegawaiPasswordController = TextEditingController();
  final _pelangganFormKey = GlobalKey<FormState>();
  final _pelangganNamaController = TextEditingController();
  final _pelangganAlamatController = TextEditingController();
  final _pelangganNoTelpController = TextEditingController();

  List<Map<String, dynamic>> _pegawaiList = [];
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

  Future<bool> _showDeleteConfirmationDialog(
      String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text('Hapus', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _isPegawaiDuplicate(String username) async {
    return _pegawaiList.any((pegawai) =>
        pegawai['username'].toLowerCase() == username.toLowerCase() &&
        pegawai['userid'] != _editingPegawaiId);
  }

  Future<bool> _isPelangganDuplicate(
      String nama, String alamat, String noTelp) async {
    return _pelangganList.any((pelanggan) =>
        pelanggan['nama'].toLowerCase() == nama.toLowerCase() &&
        pelanggan['alamat'].toLowerCase() == alamat.toLowerCase() &&
        pelanggan['no_tlp'] == noTelp &&
        pelanggan['pelangganid'] != _editingPelangganId);
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
      final isDuplicate =
          await _isPegawaiDuplicate(_pegawaiUsernameController.text);

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Username sudah digunakan. Silakan gunakan username lain.')),
          );
        }
        return;
      }

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
      final isDuplicate = await _isPelangganDuplicate(
          _pelangganNamaController.text,
          _pelangganAlamatController.text,
          _pelangganNoTelpController.text);

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Data pelanggan sudah ada. Silakan periksa kembali data yang dimasukkan.')),
          );
        }
        return;
      }

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

  Future<void> _handlePegawaiUpdate(
      int id, String username, String password) async {
    try {
      final isDuplicate = await _isPegawaiDuplicate(username);

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Username sudah digunakan. Silakan gunakan username lain.')),
          );
        }
        return;
      }

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
  }

  Future<void> _handlePelangganUpdate(
      int id, String nama, String alamat, String noTelp) async {
    try {
      final isDuplicate = await _isPelangganDuplicate(nama, alamat, noTelp);

      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Data pelanggan sudah ada. Silakan periksa kembali data yang dimasukkan.')),
          );
        }
        return;
      }

      await CrudServices.updatePelanggan(id, nama, alamat, noTelp);
      _resetPelangganForm();
      await _loadInitialData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handlePegawaiDelete(Map<String, dynamic> pegawai) async {
    final willDelete = await _showDeleteConfirmationDialog('Hapus Pegawai',
        'Apakah Anda yakin ingin menghapus pegawai "${pegawai['username']}"?');

    if (willDelete) {
      try {
        await CrudServices.deletePegawai(pegawai['userid']);
        await _loadInitialData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pegawai berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _handlePelangganDelete(Map<String, dynamic> pelanggan) async {
    final willDelete = await _showDeleteConfirmationDialog('Hapus Pelanggan',
        'Apakah Anda yakin ingin menghapus pelanggan "${pelanggan['nama']}"?');

    if (willDelete) {
      try {
        await CrudServices.deletePelanggan(pelanggan['pelangganid']);
        await _loadInitialData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pelanggan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
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
                    final pegawai =
                        _pegawaiList.firstWhere((p) => p['userid'] == id);
                    await _handlePegawaiDelete(pegawai);
                  },
                  onUpdate: _handlePegawaiUpdate,
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
                    final pelanggan = _pelangganList
                        .firstWhere((p) => p['pelangganid'] == id);
                    await _handlePelangganDelete(pelanggan);
                  },
                  onUpdate: _handlePelangganUpdate,
                  onCancelEdit: _resetPelangganForm,
                ),
              ],
            ),
    );
  }
}
