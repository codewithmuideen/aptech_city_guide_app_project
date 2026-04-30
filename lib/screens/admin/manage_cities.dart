import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/city.dart';
import '../../providers/city_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/image_source_picker.dart';
import '../../widgets/smart_image.dart';

class ManageCitiesScreen extends StatelessWidget {
  const ManageCitiesScreen({super.key});

  void _openEditor(BuildContext context, {City? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CityEditorSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final city = context.watch<CityProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Cities (${city.cities.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            tooltip: 'Add city',
            onPressed: () => _openEditor(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add City'),
      ),
      body: city.cities.isEmpty
          ? const Center(child: Text('No cities yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: city.cities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final c = city.cities[i];
                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SmartImage(
                          source: c.imageUrl, width: 64, height: 64),
                    ),
                    title: Text(c.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c.country),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openEditor(context, existing: c)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete city?'),
                              content: Text(
                                  'This will also remove all attractions in ${c.name}.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) {
                            await context.read<CityProvider>().deleteCity(c.id);
                          }
                        },
                      ),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}

class _CityEditorSheet extends StatefulWidget {
  final City? existing;
  const _CityEditorSheet({this.existing});

  @override
  State<_CityEditorSheet> createState() => _CityEditorSheetState();
}

class _CityEditorSheetState extends State<_CityEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _country;
  late TextEditingController _description;
  late TextEditingController _image;
  late TextEditingController _lat;
  late TextEditingController _lng;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _country = TextEditingController(text: e?.country ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _image = TextEditingController(text: e?.imageUrl ?? '');
    _lat = TextEditingController(text: e?.latitude.toString() ?? '');
    _lng = TextEditingController(text: e?.longitude.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    _description.dispose();
    _image.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please choose or paste a city image')));
      return;
    }
    final provider = context.read<CityProvider>();
    final city = City(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      country: _country.text.trim(),
      description: _description.text.trim(),
      imageUrl: _image.text.trim(),
      latitude: double.tryParse(_lat.text.trim()) ?? 0,
      longitude: double.tryParse(_lng.text.trim()) ?? 0,
    );
    if (widget.existing == null) {
      await provider.addCity(city);
    } else {
      await provider.updateCity(city);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.existing == null ? 'Add City' : 'Edit City',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              CustomTextField(
                  label: 'City name',
                  controller: _name,
                  validator: (v) =>
                      Validators.notEmpty(v, label: 'City name')),
              CustomTextField(
                  label: 'Country',
                  controller: _country,
                  validator: (v) => Validators.notEmpty(v, label: 'Country')),
              CustomTextField(
                label: 'Description',
                controller: _description,
                maxLines: 3,
                validator: (v) => Validators.notEmpty(v, label: 'Description'),
              ),
              ImageSourcePicker(controller: _image, label: 'City image'),
              if (_image.text.trim().isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                      'Pick a photo or paste a URL - this image is used as the city hero.',
                      style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
                ),
              Row(children: [
                Expanded(
                  child: CustomTextField(
                      label: 'Latitude',
                      controller: _lat,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.notEmpty(v, label: 'Latitude')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                      label: 'Longitude',
                      controller: _lng,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.notEmpty(v, label: 'Longitude')),
                ),
              ]),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
