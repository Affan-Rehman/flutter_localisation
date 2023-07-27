import 'package:flutter/material.dart';
import 'package:flutter_localisation/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

Future<void> saveLocaleData(Locale locale) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('localeLanguageCode', locale.languageCode);
  await prefs.setString('localeCountryCode', locale.countryCode ?? '');
}

Future<Locale> loadLocaleData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('localeLanguageCode');
  String? countryCode = prefs.getString('localeCountryCode');
  return Locale(languageCode ?? 'en', countryCode ?? '');
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', 'US');

  @override
  void initState() {
    super.initState();
    loadLocaleData().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    saveLocaleData(locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Language Selector App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: _locale,
      supportedLocales: [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
        Locale('es', 'ES'),
      ],
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: MyHomePage(setLocale),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ValueChanged<Locale> setLocale;

  MyHomePage(this.setLocale);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Locale _currentLocale = Locale('en', 'US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('selected_language')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.translate('selected_language'),
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              _currentLocale.languageCode,
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 20.0),
            DropdownButton<Locale>(
              value: _currentLocale,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  setState(() {
                    _currentLocale = newLocale;
                  });
                  widget.setLocale(newLocale);
                }
              },
              items: <Locale>[
                Locale('en', 'US'),
                Locale('fr', 'FR'),
                Locale('de', 'DE'),
                Locale('es', 'ES'),
              ]
              .map<DropdownMenuItem<Locale>>((Locale locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(locale.languageCode),  // use the language code as the display text
                );
              })
              .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
