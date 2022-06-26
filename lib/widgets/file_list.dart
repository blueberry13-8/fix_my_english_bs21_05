import 'package:flutter/material.dart';
import 'package:swp/utils/moofiy_color.dart';
import '../utils/analysis_data.dart';

class FileListController {
  late Function(List<Future<AnalyzedText>>) addNewFiles;
  List<AnalyzedText?> allAnalyzes = [];

  void addFiles(List<Future<AnalyzedText>> filesWithAnalysis) {
    addNewFiles(filesWithAnalysis);
  }
}

class FileListWidget extends StatefulWidget {
  final Function(AnalyzedText analysis) onSelected;

  final FileListController controller;
  final List<Future<AnalyzedText>> sequentialRequests;

  const FileListWidget(
      {Key? key,
      required this.controller,
      required this.sequentialRequests,
      required this.onSelected})
      : super(key: key);

  @override
  State<FileListWidget> createState() => _FileListWidget();
}

class _FileListWidget extends State<FileListWidget> {
  late List<AnalyzedText?> analyzedTexts;

  @override
  void initState() {
    super.initState();
    analyzedTexts = [];
    widget.controller.allAnalyzes = analyzedTexts;
    for (var req in widget.sequentialRequests) {
      req.then((value) {
        int nullIndex = analyzedTexts.indexOf(null);
        analyzedTexts.insert(nullIndex, value);
        analyzedTexts.remove(null);
        setState(() {});
      });
      analyzedTexts.add(null);
    }
    widget.controller.addNewFiles = _addNewFiles;
  }

  void _addNewFiles(List<Future<AnalyzedText>> filesWithAnalysis) {
    for (var fileAnalysis in filesWithAnalysis) {
      widget.sequentialRequests.add(fileAnalysis);
      fileAnalysis.then((value) {
        int nullIndex = analyzedTexts.indexOf(null);
        analyzedTexts.insert(nullIndex, value);
        analyzedTexts.remove(null);
        setState(() {});
      });
      analyzedTexts.add(null);
    }
    setState(() {});
  }

  void _removeFile(AnalyzedText textToRemove) {
    analyzedTexts.remove(textToRemove);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFFBFDF7),
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (analyzedTexts[index] == null) {
              return const ListTile(
                leading: CircularProgressIndicator(),
                title: Text(
                  "Loading...",
                  style: TextStyle(fontSize: 18, fontFamily: "Merriweather"),
                ),
              );
            } else {
              return Card(
                  color: MoofiyColors.colorSecondaryLightGreenPlant,
                  child: InkWell(
                    onTap: () {
                      widget.onSelected(analyzedTexts[index]!);
                    },
                    child: ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        size: 30,
                        color: MoofiyColors.colorSecondaryGreenPlant,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 30,
                          color: MoofiyColors.colorSecondaryGreenPlant,
                        ),
                        onPressed: () {
                          _removeFile(analyzedTexts[index]!);
                        },
                      ),
                      title: Text(
                        analyzedTexts[index]!.filename!,
                        style: const TextStyle(
                            fontSize: 18, fontFamily: "Merriweather"),
                      ),
                    ),
                  ));
            }
          },
          itemCount: analyzedTexts.length,
        ),
      ),
    );
  }
}
