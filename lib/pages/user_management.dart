import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const UserManagementPage(),
    );
  }
}

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Pegawai Form
  final _pegawaiFormKey = GlobalKey<FormState>();
  final _pegawaiUsernameController = TextEditingController();
  final _pegawaiPasswordController = TextEditingController();

  // Pelanggan Form
  final _pelangganFormKey = GlobalKey<FormState>();
  final _pelangganNamaController = TextEditingController();
  final _pelangganAlamatController = TextEditingController();
  final _pelangganNoTelpController = TextEditingController();

  // Data
  List<Map<String, dynamic>> _pegawaiList = [];
  List<Map<String, dynamic>> _pelangganList = [];
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

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
    await Future.wait([_loadPegawai(), _loadPelanggan()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadPegawai() async {
    try {
      final response = await _supabase
          .from('user')
          .select()
          .eq('role', 'pegawai')
          .order('userid');
      setState(() {
        _pegawaiList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error loading pegawai', e.toString());
    }
  }

  Future<void> _loadPelanggan() async {
    try {
      final response =
          await _supabase.from('pelanggan').select().order('pelangganid');
      setState(() {
        _pelangganList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      _showError('Error loading pelanggan', e.toString());
    }
  }

  void _showError(String title, String message) {
    print('$title: $message'); // Debugging
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _addPegawai() async {
    if (!_pegawaiFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Insert langsung ke tabel user
      await _supabase.from('user').insert({
        'username': _pegawaiUsernameController.text,
        'password': _pegawaiPasswordController.text,
        'role': 'pegawai',
        'created_at': DateTime.now().toIso8601String(),
      });

      _clearPegawaiForm();
      await _loadPegawai();
      _showSuccess('Pegawai berhasil ditambahkan');
    } catch (e) {
      _showError('Error menambahkan pegawai', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPelanggan() async {
    if (!_pelangganFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      //terhubung denfgan tabel pelanggan
      await _supabase.from('pelanggan').insert({
        'nama': _pelangganNamaController.text,
        'alamat': _pelangganAlamatController.text,
        'no_tlp': _pelangganNoTelpController.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      _clearPelangganForm();
      await _loadPelanggan();
      _showSuccess('Pelanggan berhasil ditambahkan');
    } catch (e) {
      _showError('Error menambahkan pelanggan', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePegawai(int id) async {
    setState(() => _isLoading = true);
    try {
      await _supabase.from('user').delete().eq('userid', id);
      await _loadPegawai();
      _showSuccess('Pegawai berhasil dihapus');
    } catch (e) {
      _showError('Error menghapus pegawai', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePelanggan(int id) async {
    setState(() => _isLoading = true);
    try {
      await _supabase.from('pelanggan').delete().eq('pelangganid', id);
      await _loadPelanggan();
      _showSuccess('Pelanggan berhasil dihapus');
    } catch (e) {
      _showError('Error menghapus pelanggan', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearPegawaiForm() {
    _pegawaiUsernameController.clear();
    _pegawaiPasswordController.clear();
  }

  void _clearPelangganForm() {
    _pelangganNamaController.clear();
    _pelangganAlamatController.clear();
    _pelangganNoTelpController.clear();
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
              children: [_buildPegawaiTab(), _buildPelangganTab()],
            ),
    );
  }

  Widget _buildPegawaiTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Form(
            key: _pegawaiFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _pegawaiUsernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Username tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pegawaiPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Password tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addPegawai,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Pegawai'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _pegawaiList.length,
              itemBuilder: (context, index) {
                final pegawai = _pegawaiList[index];
                return Card(
                  child: ListTile(
                    title: Text(pegawai['username']),
                    subtitle: Text('Role: ${pegawai['role']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deletePegawai(pegawai['userid']), // Changed to int
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPelangganTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Form(
            key: _pelangganFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _pelangganNamaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pelangganAlamatController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pelangganNoTelpController,
                  decoration: const InputDecoration(
                    labelText: 'No Telepon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'No Telepon tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addPelanggan,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Pelanggan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _pelangganList.length,
              itemBuilder: (context, index) {
                final pelanggan = _pelangganList[index];
                return Card(
                  child: ListTile(
                    title: Text(pelanggan['nama']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alamat: ${pelanggan['alamat']}'),
                        Text('No. Telp: ${pelanggan['no_tlp']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deletePelanggan(pelanggan['pelangganid']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
