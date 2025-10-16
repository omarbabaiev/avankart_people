import 'package:avankart_people/assets/image_assets.dart';
import 'package:avankart_people/controllers/search_controller.dart' as search;
import 'package:avankart_people/controllers/home_controller.dart';
import 'package:avankart_people/widgets/company_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';

class SearchCompanyScreen extends StatefulWidget {
  @override
  _SearchCompanyScreenState createState() => _SearchCompanyScreenState();
}

class _SearchCompanyScreenState extends State<SearchCompanyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late search.SearchController searchController;

  @override
  void initState() {
    super.initState();
    searchController = Get.put(search.SearchController());

    // TextField'a sayfa açılır açılmaz focus ver ve klavye aç
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // HomeController'dan search query'yi al ve text field'a yaz
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        final currentSearchQuery = homeController.currentSearchQuery;
        if (currentSearchQuery.isNotEmpty) {
          _searchController.text = currentSearchQuery;
          searchController.updateSearchQuery(currentSearchQuery);
        }
      }

      // Focus'u biraz geciktir ki keyboard düzgün açılsın
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(68),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Hero(
                tag: Get.arguments?['heroTag'] ?? 'search_company',
                child: Container(
                  color: Theme.of(context).colorScheme.onPrimary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_searchController.text.isNotEmpty) {
                                      searchController.searchCompanies(
                                          _searchController.text);
                                    }
                                  },
                                  child: Image.asset(
                                    ImageAssets.searchNormal,
                                    width: 24,
                                    height: 24,
                                    color: Theme.of(context)
                                        .bottomNavigationBarTheme
                                        .unselectedItemColor,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      autofocus:
                                          false, // Manual focus kullanıyoruz
                                      textInputAction: TextInputAction.search,
                                      onChanged: (value) {
                                        searchController
                                            .updateSearchQuery(value);
                                      },
                                      onSubmitted: (value) {
                                        if (value.isNotEmpty) {
                                          searchController
                                              .searchCompanies(value);
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .bottomNavigationBarTheme
                                              .unselectedItemColor
                                              ?.withOpacity(.8),
                                        ),
                                        fillColor: Colors.transparent,
                                        hintText: 'search_placeholder'.tr,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .bottomNavigationBarTheme
                                            .unselectedItemColor
                                            ?.withOpacity(.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        CupertinoButton(
                          onPressed: () {
                            searchController.onCancelPressed();
                          },
                          child: Text(
                            'cancel'.tr,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Theme.of(context).unselectedWidgetColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 4,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              Expanded(
                child: Obx(() {
                  // Eğer arama yapılıyorsa loading göster
                  if (searchController.isSearching) {
                    return Stack(
                      children: [
                        // Ana içerik (history)
                        _buildSearchHistory(),
                        // Loading overlay
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Platform.isIOS
                                      ? CupertinoActivityIndicator()
                                      : CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'searching'.tr,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Eğer search query varsa ve arama yapılmışsa sonuçları göster
                  if (searchController.searchQuery.isNotEmpty &&
                      (searchController.searchResults.isNotEmpty ||
                          searchController.noResultsFound)) {
                    return _buildSearchResults();
                  }

                  // Yoksa search history'yi göster
                  return _buildSearchHistory();
                }),
              )
            ],
          ),
        ));
  }

  // Search history widget'ı
  Widget _buildSearchHistory() {
    return Container(
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.onPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'search_history'.tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: Theme.of(context).unselectedWidgetColor,
            ),
          ),
          SizedBox(height: 6),
          if (searchController.searchHistory.isEmpty)
            Text(
              'no_search_history'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            )
          else
            ...searchController.searchHistory
                .map((query) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        query,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          // History'den sil
                          searchController.removeFromSearchHistory(query);
                        },
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).unselectedWidgetColor,
                          size: 24,
                        ),
                      ),
                      onTap: () {
                        _searchController.text = query;
                        searchController.updateSearchQuery(query);
                        // Focus'u geciktir
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (mounted) {
                            _searchFocusNode.requestFocus();
                          }
                        });
                        // History'deki search'e basınca arama yap
                        searchController.searchCompanies(query);
                      },
                    ))
                .toList(),
        ],
      ),
    );
  }

  // Search results widget'ı
  Widget _buildSearchResults() {
    if (searchController.isSearching) {
      return Center(
        child: Platform.isIOS
            ? CupertinoActivityIndicator()
            : CircularProgressIndicator(),
      );
    }

    // Eğer sonuç bulunamadıysa "Sonuç bulunamadı" mesajı göster
    if (searchController.noResultsFound) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageAssets.searchfavoriteicon,
              height: 64,
              width: 64,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            SizedBox(height: 16),
            Text(
              'no_results_found'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'no_company_found_description'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (searchController.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageAssets.searchfavoriteicon,
              height: 64,
              width: 64,
              color: Theme.of(context).unselectedWidgetColor,
            ),
            SizedBox(height: 16),
            Text(
              'start_searching'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Theme.of(context).unselectedWidgetColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'search_company_hint'.tr,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Theme.of(context).unselectedWidgetColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: searchController.searchResults.length,
      itemBuilder: (context, index) {
        final company = searchController.searchResults[index];
        return CompanyCard(
          name: company.muessiseName,
          index: index,
          location: company.location,
          distance: company.distance.toString(),
          imageUrl: company.profileImagePath ?? '',
          type: 'business',
          companyId: company.id,
          isOpen: true,
          isFavorite: company.isFavorite,
        );
      },
    );
  }
}
