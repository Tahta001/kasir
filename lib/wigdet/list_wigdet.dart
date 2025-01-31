//berisi list di halaman register/user menegement
import 'package:flutter/material.dart';

class PegawaiList extends StatelessWidget {
  final List<Map<String, dynamic>> pegawaiList;
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isEditing;
  final int? editingId;
  final Future<void> Function() onAdd;
  final Future<void> Function(Map<String, dynamic>) onStartEdit;
  final Future<void> Function(int) onDelete;
  final Future<void> Function(int, String, String)
      onUpdate; //int=id, string=pass/usn
  final VoidCallback onCancelEdit;

  const PegawaiList({
    super.key,
    required this.pegawaiList,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.isEditing,
    this.editingId,
    required this.onAdd,
    required this.onStartEdit,
    required this.onDelete,
    required this.onUpdate,
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      //membungkus seluruh tambilan column
      children: [
        Padding(
          //unutk atas yaitu form imput
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Edit Username' : 'Username',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Username tidak boleh kosong' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: isEditing
                        ? 'Edit Password (kosongkan jika tidak diubah)'
                        : 'Password',
                  ),
                  obscureText: true,
                  validator: (value) => !isEditing && value!.isEmpty
                      ? 'Password tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isEditing)
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              await onAdd();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Pegawai'),
                      )
                    else ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              await onUpdate(
                                editingId!,
                                usernameController.text,
                                passwordController.text,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onCancelEdit,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Batal'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(//bafian bawa yaitu list pegawi
          child: ListView.builder(
            itemCount: pegawaiList.length,
            itemBuilder: (context, index) {
              final pegawai = pegawaiList[index];
              return ListTile(
                title: Text(pegawai['username']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        try {
                          await onStartEdit(pegawai);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await onDelete(pegawai['userid']);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PelangganList extends StatelessWidget {
  final List<Map<String, dynamic>> pelangganList;
  final GlobalKey<FormState> formKey;
  final TextEditingController namaController;
  final TextEditingController alamatController;
  final TextEditingController noTelpController;
  final bool isEditing;
  final int? editingId;
  final Future<void> Function() onAdd;
  final Future<void> Function(Map<String, dynamic>) onStartEdit;
  final Future<void> Function(int) onDelete;
  final Future<void> Function(int, String, String, String) onUpdate;
  final VoidCallback onCancelEdit;

  const PelangganList({
    super.key,
    required this.pelangganList,
    required this.formKey,
    required this.namaController,
    required this.alamatController,
    required this.noTelpController,
    required this.isEditing,
    this.editingId,
    required this.onAdd,
    required this.onStartEdit,
    required this.onDelete,
    required this.onUpdate,
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Edit Nama' : 'Nama',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: alamatController,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Edit Alamat' : 'Alamat',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: noTelpController,
                  decoration: InputDecoration(
                    labelText: isEditing ? 'Edit No Telepon' : 'No Telepon',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'No Telepon tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isEditing)
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              await onAdd();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Pelanggan'),
                      )
                    else ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              await onUpdate(
                                editingId!,
                                namaController.text,
                                alamatController.text,
                                noTelpController.text,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onCancelEdit,
                        icon: const Icon(Icons.cancel),
                        label: const Text('Batal'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pelangganList.length,
            itemBuilder: (context, index) {
              final pelanggan = pelangganList[index];
              return ListTile(
                title: Text(pelanggan['nama']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alamat: ${pelanggan['alamat']}'),
                    Text('No Telp: ${pelanggan['no_tlp']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        try {
                          await onStartEdit(pelanggan);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await onDelete(pelanggan['pelangganid']);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
