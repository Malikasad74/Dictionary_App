import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dictionary_model.dart';
import 'services.dart';

class DictionaryHomePage extends StatefulWidget {
  const DictionaryHomePage({super.key});

  @override
  State<DictionaryHomePage> createState() => _DictionaryHomePageState();
}

class _DictionaryHomePageState extends State<DictionaryHomePage> {
  DictionaryModel? dictionaryModel;
  bool isLoading = false;
  bool hasInternet = true;
  String statusMessage = "Now You Can Search";

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  /// Check Internet Connection
  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      hasInternet = connectivityResult != ConnectivityResult.none;
    });
  }

  /// Fetch Dictionary Data
  Future<void> fetchDictionaryData(String word) async {
    await checkInternetConnection(); // Check connection before making API call

    if (!hasInternet) {
      setState(() {
        statusMessage = "No Internet Connection";
        dictionaryModel = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      dictionaryModel = null;
      statusMessage = "Searching...";
    });

    try {
      dictionaryModel = await APIservices.fetchData(word);
      if (dictionaryModel == null) {
        setState(() {
          statusMessage = "Meaning can't be found";
        });
      } else {
        setState(() {
          statusMessage = "";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Error occurred. Please try again.";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dictionary App"),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SearchBar(
              hintText: "Enter a word...",
              onSubmitted: (value) {
                if (value.isNotEmpty) fetchDictionaryData(value);
              },
            ),
          ),
          const SizedBox(height: 10),

          // Body Content
          Expanded(
            child: Center(
              child: hasInternet
                  ? isLoading
                      ? const CircularProgressIndicator()
                      : dictionaryModel != null
                          ? buildDictionaryContent()
                          : Text(
                              statusMessage,
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.grey),
                            )
                  : const Text(
                      "No Internet Connection",
                      style: TextStyle(fontSize: 22, color: Colors.red),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Dictionary Content
  Widget buildDictionaryContent() {
    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: [
        // Word Title
        Text(
          dictionaryModel!.word,
          style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 10),

        // Phonetics
        if (dictionaryModel!.phonetics.isNotEmpty)
          Text(
            "Pronunciation: ${dictionaryModel!.phonetics[0].text ?? ""}",
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),

        // Meanings
        ...dictionaryModel!.meanings.map(
          (meaning) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(
                  meaning.partOfSpeech,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    ...meaning.definitions.map((definition) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          "- ${definition.definition}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
