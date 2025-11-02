import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/query_controller.dart';
import 'package:avankart_people/models/reason_model.dart';
import 'package:avankart_people/services/query_service.dart';
import 'package:avankart_people/routes/app_routes.dart';
import 'package:avankart_people/utils/app_theme.dart';
import 'package:avankart_people/utils/bottom_sheet_extension.dart';
import 'package:avankart_people/utils/toast_utils.dart';
import 'package:avankart_people/widgets/pagination_widgets/platform_reload_widget.dart';
import 'package:avankart_people/widgets/settings_widgets/settings_radio_item.dart';
import 'package:avankart_people/widgets/support_widgets/query_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class QueryScreen extends GetView<QueryController> {
  QueryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat
    Get.put(QueryController());

    // Scroll controller'ı build metodunda oluştur
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        // Son 200 piksel kaldığında daha fazla veri yükle
        if (controller.hasMoreData.value && !controller.isLoading.value) {
          controller.loadMore();
        }
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'queries'.tr,
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
              "create_new_query".tr,
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
            onRefresh: controller.refresh,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Skeletonizer(
              enableSwitchAnimation: true,
              enabled: isLoading,
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: isLoading
                    ? 5
                    : isEmpty
                        ? 1
                        : controller.queries.length +
                            (controller.hasMoreData.value ? 1 : 0),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 200),
                          Image.asset(ImageAssets.queryEmpty, height: 80),
                          SizedBox(height: 8),
                          Text(
                            'no_query_found'.tr,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'no_query_found_description'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 16),
                          CupertinoButton(
                            onPressed: () {
                              _createQuery(context);
                            },
                            child: Text(
                              'create_new_query'.tr,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Load more indicator
                  if (index == controller.queries.length) {
                    return PlatformReloadWidget(
                      isLoading: controller.isLoading.value,
                      hasMoreData: controller.hasMoreData.value,
                      onRetry: () {
                        controller.loadMore();
                      },
                      errorMessage: controller.errorMessage.value.isNotEmpty
                          ? controller.errorMessage.value
                          : null,
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

    // Query service'i başlat
    final QueryService _queryService = QueryService();

    // Kategori seçenekleri
    final List<String> categoryOptions = [
      'general'.tr,
      'account_problem'.tr,
      'payment_problem'.tr
    ];
    String? _selectedCategory;

    // Kategori mapping (UI -> API)
    final Map<String, String> categoryMapping = {
      'general'.tr: 'general',
      'account_problem'.tr: 'account',
      'payment_problem'.tr: 'pay',
    };

    // Problem sebepleri ve seçimleri için map
    final Map<String, bool> problemReasons = {};

    // Seçili sebep sayısı
    final RxInt selectedReasonCount = 0.obs;

    // Seçili dosyalar
    final RxList<String> selectedFiles = <String>[].obs;

    // Reason data'sını yükle
    final RxBool isLoadingReasons = false.obs;
    final RxList<ReasonModel> currentReasons = <ReasonModel>[].obs;

    // Reason'ları yükle
    Future<void> loadReasons() async {
      if (_selectedCategory == null) return;

      try {
        isLoadingReasons.value = true;
        final response = await _queryService.getReasons();

        // Seçili kategoriye göre reason'ları filtrele
        final categoryKey = categoryMapping[_selectedCategory!];
        if (categoryKey != null) {
          final categoryReasons = response.getReasonsForCategory(categoryKey);
          currentReasons.assignAll(categoryReasons);

          // Problem reasons map'ini güncelle
          problemReasons.clear();
          for (final reason in categoryReasons) {
            problemReasons[reason.text] =
                false; // reason.name yerine reason.text kullan
          }
        }
      } catch (e) {
        ToastUtils.showErrorToast('error_loading_reasons'.tr + ' $e');
      } finally {
        isLoadingReasons.value = false;
      }
    }

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
                      'create_query'.tr,
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
                      'support_subtitle'.tr,
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
                    'query_category'.tr,
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
                          // Kategori seçildiğinde reason'ları yükle
                          loadReasons();
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
                            _selectedCategory ?? 'select_option'.tr,
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
                    'problem_reason'.tr,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectedCategory == null
                        ? null
                        : () {
                            // Bottom sheet ile problem sebepleri seçimi
                            _showProblemReasonsBottomSheet(
                                context, problemReasons, (updatedReasons) {
                              setState(() {
                                problemReasons.clear();
                                problemReasons.addAll(updatedReasons);
                                selectedReasonCount.value = problemReasons
                                    .values
                                    .where((v) => v)
                                    .length;
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
                                    ? '${selectedReasonCount.value} ${'selections_made'.tr}'
                                    : 'select_option'.tr,
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
                    'subject'.tr,
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
                    hintText: 'enter_your_name'.tr,
                  ),

                  const SizedBox(height: 16),

                  // Probleminiz
                  Text(
                    'your_problem'.tr,
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
                    hintText: 'describe_problem'.tr,
                    maxLines: 3,
                  ),

                  // Şəkil və fayl əlavə et
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () async {
                      // Dosya seçme işlemi
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        allowMultiple: true,
                      );

                      if (result != null) {
                        selectedFiles.value =
                            result.files.map((file) => file.path!).toList();
                        ToastUtils.showSuccessToast('files_selected'.tr);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'add_image_or_file'.tr,
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

                  // Seçili dosyaları göster
                  Obx(() {
                    if (selectedFiles.isEmpty) {
                      return SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'selected_files'.tr,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...selectedFiles.map((filePath) {
                          final fileName = filePath.split('/').last;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fileName,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    selectedFiles.remove(filePath);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }),

                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Form validation
                        if (_titleController.text.trim().isEmpty) {
                          ToastUtils.showErrorToast('title_required'.tr);
                          return;
                        }

                        if (_descriptionController.text.trim().isEmpty) {
                          ToastUtils.showErrorToast('description_required'.tr);
                          return;
                        }

                        if (_selectedCategory == null) {
                          ToastUtils.showErrorToast('category_required'.tr);
                          return;
                        }

                        // Create query
                        final success = await controller.createQuery(
                          reason: selectedReasonCount.value > 0
                              ? problemReasons.entries
                                  .where((entry) => entry.value)
                                  .map((entry) => entry.key)
                                  .toList()
                              : [],
                          title: selectedReasonCount.value > 0
                              ? problemReasons.entries
                                  .where((entry) => entry.value)
                                  .map((entry) => entry.key)
                                  .join(
                                      ', ') // Seçilen reason'ları title olarak gönder
                              : _titleController.text.trim(),
                          content: _descriptionController.text
                              .trim(), // Problem description'ı content olarak gönder
                          description: _descriptionController.text.trim(),
                          category:
                              categoryMapping[_selectedCategory!] ?? 'general',
                          files: selectedFiles, // Seçili dosyaları gönder
                        );

                        if (success) {
                          _showSuccessBottomSheet(context);
                        }
                      },
                      style: AppTheme.primaryButtonStyle(),
                      child: Text(
                        'send_query'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
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
    final RxBool isLoadingReasons = false.obs;

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
                Obx(() {
                  if (isLoadingReasons.value) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (tempReasons.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Önce kategori seçin',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: tempReasons.keys.map((reason) {
                      return Column(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              checkboxTheme: CheckboxThemeData(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                fillColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Theme.of(context)
                                        .colorScheme
                                        .primary;
                                  }
                                  return Colors.transparent;
                                }),
                                side: BorderSide(
                                  color:
                                      Theme.of(context).unselectedWidgetColor,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                  );
                }),
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
                'request_sent'.tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'problem_solution_message'.tr,
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
                    'completed'.tr,
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
