import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/history_model.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
// import 'dart:typed_data';

class HistoryController extends GetxController {
  final _supabase = Supabase.instance.client;
  final history = <History>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // Filter-related observables
  final wilayas = <String>[].obs;
  final dayras = <String>[].obs;
  final baladias = <String>[].obs;
  final plantNames = <String>[].obs;
  final createdByUsers = <String>[].obs;

  // Selected values
  final selectedWilaya = Rxn<String>();
  final selectedDayra = Rxn<String>();
  final selectedBaladia = Rxn<String>();
  final selectedPlantName = Rxn<String>();
  final selectedCreatedBy = Rxn<String>();
  final selectedStartDate = Rxn<DateTime>();
  final selectedEndDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    fetchFilterData();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading(true);
      error('');

      final response = await _supabase
          .from('history')
          .select('*, users!inner(full_name)')
          .order('created_at', ascending: false);

      final List<History> fetchedHistory = (response as List).map((json) {
        // Create a modified json with the creator's name from the joined users table
        return History.fromJson({
          ...json,
          'created_by': json['users']['full_name'],
        });
      }).toList();

      history.assignAll(fetchedHistory);
    } catch (e) {
      error('Erreur lors de la récupération de l\'historique: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<String?> exportToExcel() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Create a new Excel document
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Historique'];

      // Add headers
      sheetObject.appendRow([
        'plantName',
        'quantity',
        'space',
        'wilaya',
        'dayra',
        'baladya',
        'createdBy',
        'createdAt',
      ]);

      // Add data rows
      for (var record in history) {
        sheetObject.appendRow([
          record.plantName,
          record.quantity,
          record.space,
          record.wilaya,
          record.dayra,
          record.baladya,
          record.createdBy,
          record.date.toIso8601String(),
          // final String plantName;
          // final String quantity;
          // final String space;
          // final String wilaya;
          // final String dayra;
          // final String baladya;
          // final String createdBy;
          // final DateTime date;
        ]);
      }

      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'historique_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final String filePath = '${directory.path}/$fileName';

      // Save the file
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        return filePath;
      }
      return null;
    } catch (e) {
      error.value = 'Erreur lors de l\'exportation vers Excel: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> exportToExcelWithDialog() async {
    try {
      isLoading.value = true;
      error.value = '';

      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      sheet.name = 'Historique';

      // Add headers
      final headers = [
        'Nom de la plante',
        'Quantité',
        'Espace',
        'Wilaya',
        'Dayra',
        'Baladya',
        'Créé par',
        'Date'
      ];
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }

      // Add data rows
      for (int i = 0; i < history.length; i++) {
        final record = history[i];
        sheet.getRangeByIndex(i + 2, 1).setText(record.plantName);
        sheet.getRangeByIndex(i + 2, 2).setText(record.quantity);
        sheet.getRangeByIndex(i + 2, 3).setText(record.space);
        sheet.getRangeByIndex(i + 2, 4).setText(record.wilaya);
        sheet.getRangeByIndex(i + 2, 5).setText(record.dayra);
        sheet.getRangeByIndex(i + 2, 6).setText(record.baladya);
        sheet.getRangeByIndex(i + 2, 7).setText(record.createdBy);
        sheet
            .getRangeByIndex(i + 2, 8)
            .setText(DateFormat('dd/MM/yyyy HH:mm').format(record.date));
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String? directoryPath = await getDirectoryPath();
      if (directoryPath == null) {
        return null; // User cancelled
      }

      // Compose the full file path with your desired file name
      final String fileName = 'historique_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
      final String filePath = '$directoryPath/$fileName';

      // Now you can write to this file
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      return filePath;
    } catch (e) {
      error.value = 'Erreur lors de l\'exportation vers Excel: $e';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFilterData() async {
    try {
      isLoading.value = true;

      // Fetch all users
      final usersResponse =
          await _supabase.from('users').select('full_name').order('full_name');
      createdByUsers.value = (usersResponse as List)
          .map((e) => e['full_name'] as String)
          .toSet() // Remove duplicates
          .toList();

      // Fetch all plant names
      final plantsResponse =
          await _supabase.from('plants').select('name').order('name');
      plantNames.value = (plantsResponse as List)
          .map((e) => e['name'] as String)
          .toSet() // Remove duplicates
          .toList();

      // Fetch all places data
      final placesResponse = await _supabase
          .from(
              'place') // Changed from 'places' to 'place' to match your table name
          .select('wilaya, dayra, baladya')
          .order('wilaya');

      print('Places data fetched: $placesResponse'); // Debug print

      if (placesResponse != null) {
        final places = placesResponse as List;
        
        // Get all wilayas
        wilayas.value = places
            .map((e) => e['wilaya'] as String)
            .where((w) => w != null && w.isNotEmpty)
            .toList();
        print('Wilayas: ${wilayas.value}'); // Debug print
        
        // Get all dayras
        dayras.value = places
            .map((e) => e['dayra'] as String)
            .where((d) => d != null && d.isNotEmpty)
            .toList();
        print('Dayras: ${dayras.value}'); // Debug print
        
        // Get all baladyas
        baladias.value = places
            .map((e) => e['baladya'] as String)
            .where((b) => b != null && b.isNotEmpty)
            .toList();
        print('Baladyas: ${baladias.value}'); // Debug print
      }
    } catch (e) {
      error.value =
          'Erreur lors de la récupération des données de filtrage: $e';
      print('Error in fetchFilterData: $e'); // Debug print
    } finally {
      isLoading.value = false;
    }
  }

  void setDateRange(DateTime? start, DateTime? end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
  }

  Future<void> applyFilters() async {
    try {
      isLoading.value = true;
      error.value = '';

      var query = _supabase.from('history').select('*, users!inner(full_name)');

      // Apply filters
      final plantName = selectedPlantName.value;
      if (plantName != null) {
        query = query.eq('plant_name', plantName);
      }

      final createdBy = selectedCreatedBy.value;
      if (createdBy != null) {
        query = query.eq('users.full_name', createdBy);
      }

      final wilaya = selectedWilaya.value;
      if (wilaya != null) {
        query = query.eq('wilaya', wilaya);
      }

      final dayra = selectedDayra.value;
      if (dayra != null) {
        query = query.eq('dayra', dayra);
      }

      final baladia = selectedBaladia.value;
      if (baladia != null) {
        query = query.eq('baladya', baladia);
      }

      final startDate = selectedStartDate.value;
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      final endDate = selectedEndDate.value;
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      final List<History> filteredHistory = (response as List).map((json) {
        return History.fromJson({
          ...json,
          'created_by': json['users']['full_name'],
        });
      }).toList();
      
      history.assignAll(filteredHistory);
    } catch (e) {
      error.value = 'Erreur lors de l\'application des filtres: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    selectedWilaya.value = null;
    selectedDayra.value = null;
    selectedBaladia.value = null;
    selectedPlantName.value = null;
    selectedCreatedBy.value = null;
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    dayras.clear();
    baladias.clear();
    fetchHistory();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy,HH:mm').format(date);
  }
}
