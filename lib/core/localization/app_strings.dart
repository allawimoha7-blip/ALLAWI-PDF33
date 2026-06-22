import 'package:flutter/material.dart';

/// Lightweight, hand-rolled localization (no codegen) so the project
/// builds immediately without running `flutter gen-l10n`.
///
/// For a larger app this would move to ARB files + `flutter_localizations`
/// codegen, but a static map keeps the example self-contained and easy
/// to extend — just add a key to both maps below.
class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings) ?? AppStrings(const Locale('en'));
  }

  static const supportedLocales = [Locale('en'), Locale('ar')];

  bool get isArabic => locale.languageCode == 'ar';

  static const Map<String, String> _en = {
    'appName': 'ALLAWI PDF Reader',
    'tagline': 'Read PDFs Faster, Smarter, Better.',
    'home': 'Home',
    'recent': 'Recent',
    'favorites': 'Favorites',
    'files': 'Files',
    'settings': 'Settings',
    'openFile': 'Open a PDF',
    'noRecentFiles': 'No recent files yet',
    'noRecentFilesSub': 'PDFs you open will show up here',
    'noFavorites': 'No favorites yet',
    'noFavoritesSub': 'Tap the star on any file to save it here',
    'noFiles': 'No PDF files found',
    'searchFiles': 'Search files',
    'searchInDocument': 'Search in document',
    'sortBy': 'Sort by',
    'name': 'Name',
    'date': 'Date',
    'size': 'Size',
    'rename': 'Rename',
    'delete': 'Delete',
    'share': 'Share',
    'addToFavorites': 'Add to favorites',
    'removeFromFavorites': 'Remove from favorites',
    'deleteConfirmTitle': 'Delete file?',
    'deleteConfirmBody': 'This will permanently delete this file from your device.',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'renameFile': 'Rename file',
    'newName': 'New name',
    'save': 'Save',
    'bookmarks': 'Bookmarks',
    'addBookmark': 'Add bookmark',
    'removeBookmark': 'Remove bookmark',
    'thumbnails': 'Pages',
    'nightMode': 'Night reading mode',
    'fullScreen': 'Full screen',
    'print': 'Print',
    'extractText': 'Extract text',
    'convertToImages': 'Convert pages to images',
    'highlight': 'Highlight',
    'addNote': 'Add note',
    'draw': 'Draw',
    'page': 'Page',
    'of': 'of',
    'darkMode': 'Dark mode',
    'lightMode': 'Light mode',
    'systemDefault': 'System default',
    'language': 'Language',
    'english': 'English',
    'arabic': 'العربية',
    'appearance': 'Appearance',
    'about': 'About',
    'version': 'Version',
    'enterPassword': 'Enter password',
    'passwordProtected': 'This PDF is password protected',
    'wrongPassword': 'Incorrect password. Try again.',
    'unlock': 'Unlock',
    'noResults': 'No results found',
    'loadingDocument': 'Loading document…',
    'readingProgress': 'Reading progress',
    'continueReading': 'Continue reading',
    'allFiles': 'All Files',
    'sharePdf': 'Share PDF',
    'organize': 'Organize',
    'createFolder': 'Create folder',
    'grantPermission': 'Allawi PDF Reader needs storage access to find your PDF files.',
    'grantPermissionAction': 'Grant permission',
  };

  static const Map<String, String> _ar = {
    'appName': 'علاوي لقراءة PDF',
    'tagline': 'اقرأ ملفات PDF بشكل أسرع وأذكى وأفضل.',
    'home': 'الرئيسية',
    'recent': 'الأخيرة',
    'favorites': 'المفضلة',
    'files': 'الملفات',
    'settings': 'الإعدادات',
    'openFile': 'فتح ملف PDF',
    'noRecentFiles': 'لا توجد ملفات حديثة',
    'noRecentFilesSub': 'ستظهر هنا ملفات PDF التي تفتحها',
    'noFavorites': 'لا توجد ملفات مفضلة',
    'noFavoritesSub': 'اضغط على النجمة في أي ملف لحفظه هنا',
    'noFiles': 'لم يتم العثور على ملفات PDF',
    'searchFiles': 'البحث في الملفات',
    'searchInDocument': 'البحث داخل المستند',
    'sortBy': 'ترتيب حسب',
    'name': 'الاسم',
    'date': 'التاريخ',
    'size': 'الحجم',
    'rename': 'إعادة تسمية',
    'delete': 'حذف',
    'share': 'مشاركة',
    'addToFavorites': 'إضافة إلى المفضلة',
    'removeFromFavorites': 'إزالة من المفضلة',
    'deleteConfirmTitle': 'حذف الملف؟',
    'deleteConfirmBody': 'سيتم حذف هذا الملف نهائيًا من جهازك.',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'renameFile': 'إعادة تسمية الملف',
    'newName': 'الاسم الجديد',
    'save': 'حفظ',
    'bookmarks': 'الإشارات المرجعية',
    'addBookmark': 'إضافة إشارة مرجعية',
    'removeBookmark': 'إزالة الإشارة المرجعية',
    'thumbnails': 'الصفحات',
    'nightMode': 'وضع القراءة الليلي',
    'fullScreen': 'ملء الشاشة',
    'print': 'طباعة',
    'extractText': 'استخراج النص',
    'convertToImages': 'تحويل الصفحات إلى صور',
    'highlight': 'تظليل',
    'addNote': 'إضافة ملاحظة',
    'draw': 'رسم',
    'page': 'صفحة',
    'of': 'من',
    'darkMode': 'الوضع الداكن',
    'lightMode': 'الوضع الفاتح',
    'systemDefault': 'إعدادات النظام',
    'language': 'اللغة',
    'english': 'English',
    'arabic': 'العربية',
    'appearance': 'المظهر',
    'about': 'حول التطبيق',
    'version': 'الإصدار',
    'enterPassword': 'أدخل كلمة المرور',
    'passwordProtected': 'هذا الملف محمي بكلمة مرور',
    'wrongPassword': 'كلمة المرور غير صحيحة. حاول مرة أخرى.',
    'unlock': 'فتح',
    'noResults': 'لا توجد نتائج',
    'loadingDocument': 'جاري تحميل المستند…',
    'readingProgress': 'تقدم القراءة',
    'continueReading': 'استمرار القراءة',
    'allFiles': 'كل الملفات',
    'sharePdf': 'مشاركة الملف',
    'organize': 'تنظيم',
    'createFolder': 'إنشاء مجلد',
    'grantPermission': 'يحتاج تطبيق علاوي إلى إذن الوصول للتخزين للعثور على ملفات PDF.',
    'grantPermissionAction': 'منح الإذن',
  };

  String t(String key) {
    final map = isArabic ? _ar : _en;
    return map[key] ?? _en[key] ?? key;
  }
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppStrings> old) => false;
}

/// Convenience extension: `context.s.t('home')`.
extension AppStringsExtension on BuildContext {
  AppStrings get s => AppStrings.of(this);
}
