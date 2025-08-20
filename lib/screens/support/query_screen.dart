import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/query_controller.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/widgets/settings_widgets/settings_radio_item.dart';
import 'package:avankart_people/widgets/support_widgets/query_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class QueryScreen extends GetView<QueryController> {
  const QueryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    Get.put(QueryController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Sorğular',
            style: TextStyle(
    fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _createQuery(context);
            },
            label: Text(
              "Sorğu göndər",
              style: TextStyle(
    fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 4),
        color: Theme.of(context).colorScheme.onPrimary,
        child: Obx(() {
          // Əgər loadingdirsə və data hələ gəlməyibsə, shimmer effekti göstər
          final isLoading = controller.isLoading.value;
          final isEmpty = controller.queries.isEmpty;

          return RefreshIndicator.adaptive(
            onRefresh: controller.fetchQueries,
            child: Skeletonizer(
              enableSwitchAnimation: true,
              enabled: isLoading,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: isLoading
                    ? 5
                    : isEmpty
                        ? 1
                        : controller.queries.length,
                itemBuilder: (context, index) {
                  if (isLoading) {
                    // Fake shimmer item
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: QueryCard(
                        id: "S-XXXXXXXX",
                        title: "Yüklənir...",
                        description: "Yüklənir...",
                        date: "XX.XX.XXXX",
                        status: "Baxılır",
                        onTap: () {},
                      ),
                    );
                  }

                  if (isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 64),
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'Heç bir sorğu tapılmadı',
                              style: TextStyle(
    fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Yeni sorgu ekleme
                              },
                              child: Text('create_new_query'.tr),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final query = controller.queries[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QueryCard(
                      id: query['id'],
                      title: query['title'],
                      description: query['description'],
                      date: query['date'],
                      status: query['status'],
                      onTap: () {
                        Get.toNamed(AppRoutes.queryDetail, arguments: {
                          "id": query["id"],
                          "title": query['title'],
                          "description": query['description'],
                          "date": query['date'],
                          "status": query['status'],
                          "files": query['files'],
                          "reason":
                              query['reason'] ?? ["dsdfffs", "dsdsd", "dsddsds"]
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  void _createQuery(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();

    // Kategori seçenekleri
    final List<String> categoryOptions = [
      'Ümumi',
      'Hesab problemi',
      'Ödəniş problemi'
    ];
    String? _selectedCategory;

    // Problem sebepleri ve seçimleri için map
    final Map<String, bool> problemReasons = {
      'Kart texniki səbəblərdən yanlış aktivləşdirilib': false,
      'Ödəniş edə bilmirəm': false,
      'QR kod scan edilmir': false,
    };

    // Seçili sebep sayısı
    final RxInt selectedReasonCount = 0.obs;

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Center(child: context.buildBottomSheetHandle()),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Sorğu yarat',
                      style: TextStyle(
    fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  SizedBox(height: 7),
                  Center(
                    child: Text(
                      'Biz buradayıq, sizə necə kömək edə bilərik?',
                      style: TextStyle(
    fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).unselectedWidgetColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sorğu kategoriyası - İnteraktif buton
                  Text(
                    'Sorğu kateqoriyası',
                    style: TextStyle(
    fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Bottom sheet ile kategori seçimi
                      _showCategoryBottomSheet(
                          context, categoryOptions, _selectedCategory, (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory ?? 'Seçim edin',
                            style: TextStyle(
    fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                          Image.asset(
                            ImageAssets.careddown,
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Problemin səbəbi - Bottom sheet ile
                  Text(
                    'Problemin səbəbi',
                    style: TextStyle(
    fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Bottom sheet ile problem sebepleri seçimi
                      _showProblemReasonsBottomSheet(context, problemReasons,
                          (updatedReasons) {
                        setState(() {
                          problemReasons.clear();
                          problemReasons.addAll(updatedReasons);
                          selectedReasonCount.value =
                              problemReasons.values.where((v) => v).length;
                        });
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() => Text(
                                selectedReasonCount.value > 0
                                    ? '${selectedReasonCount.value} seçim edildi'
                                    : 'Seçim edin',
                                style: TextStyle(
    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                              )),
                          Image.asset(
                            ImageAssets.careddown,
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mövzu
                  Text(
                    'Mövzu',
                    style: TextStyle(
    fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    context: context,
                    controller: _titleController,
                    hintText: 'Adınızı daxil edin',
                  ),

                  const SizedBox(height: 16),

                  // Probleminiz
                  Text(
                    'Probleminiz',
                    style: TextStyle(
    fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    context: context,
                    controller: _descriptionController,
                    hintText: 'Qarşılaşdığınız problemi bizə təsvir edin',
                    maxLines: 3,
                  ),

                  // Şəkil və fayl əlavə et
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () {
                      // Dosya ekleme işlemi
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Şəkil və ya fayl əlavə edin',
                          style: TextStyle(
    fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Sorgu başarılı bottom sheet göster
                        _showSuccessBottomSheet(context);
                      },
                      style: AppTheme.primaryButtonStyle(),
                      child: Text(
                        'Sorğu göndər',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // Kategori seçimi için bottom sheet
  void _showCategoryBottomSheet(BuildContext context, List<String> options,
      String? selectedValue, Function(String) onSelect) {
    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Center(child: context.buildBottomSheetHandle()),
              const SizedBox(height: 10),
              ...options.asMap().entries.map((entry) {
                final int index = entry.key;
                final String option = entry.value;

                return Column(
                  children: [
                    SettingsRadioItem(
                      title: option,
                      value: option,
                      groupValue: selectedValue,
                      onChanged: (value) {
                        onSelect(value!);
                        Get.back();
                      },
                    ),
                    // Son öğe hariç divider ekle
                    if (index < options.length - 1)
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Theme.of(context).dividerColor,
                      ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  // Problem sebepleri seçimi için bottom sheet
  void _showProblemReasonsBottomSheet(BuildContext context,
      Map<String, bool> reasons, Function(Map<String, bool>) onUpdate) {
    // Geçici bir map oluştur, orijinali güncellememek için
    final Map<String, bool> tempReasons = Map.from(reasons);

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Center(child: context.buildBottomSheetHandle()),
                const SizedBox(height: 10),
                ...tempReasons.keys.map((reason) {
                  return Column(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          checkboxTheme: CheckboxThemeData(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(MaterialState.selected)) {
                                return Theme.of(context).colorScheme.primary;
                              }
                              return Colors.transparent;
                            }),
                            side: BorderSide(
                              color: Theme.of(context).unselectedWidgetColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              tempReasons[reason] = !tempReasons[reason]!;
                            });
                            // Anlık olarak güncelle
                            onUpdate(Map.from(tempReasons));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: AppTheme.adaptiveCheckbox(
                                    value: tempReasons[reason] ?? false,
                                    onChanged: (value) {
                                      setState(() {
                                        tempReasons[reason] = value!;
                                      });
                                      // Anlık olarak güncelle
                                      onUpdate(Map.from(tempReasons));
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: TextStyle(
    fontFamily: 'Poppins',
                                      fontSize: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (reason != tempReasons.keys.last)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Theme.of(context).dividerColor,
                        ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 30),
              ],
            ),
          );
        });
      },
    );
  }

  // Başarı mesajı bottom sheet'i
  void _showSuccessBottomSheet(BuildContext context) {
    Get.back(); // Mevcut bottom sheet'i kapat

    context.showPerformantBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_upward,
                    size: 36,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Müraciətiniz göndərildi',
                style: TextStyle(
    fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ən qısa zamanda e-poçt adresinizə problemin həlli ilə bağlı mesaj göndəriləcək',
                textAlign: TextAlign.center,
                style: TextStyle(
    fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).unselectedWidgetColor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: AppTheme.primaryButtonStyle(),
                  child: Text(
                    'Tamamlandı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
    fontFamily: 'Poppins',
          fontSize: 14,
          color: Theme.of(context).splashColor,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
      ),
    );
  }
}
