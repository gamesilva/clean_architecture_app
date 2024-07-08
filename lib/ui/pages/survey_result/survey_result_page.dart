import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/components.dart';
import '../../helpers/helpers.dart';
import 'survey_result.dart';

class SurveyResultPage extends StatelessWidget {
  final SurveyResultPresenter? presenter;

  SurveyResultPage(this.presenter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.strings.surveys),
      ),
      body: Builder(
        builder: (context) {
          presenter?.isLoadingStream.listen((isLoading) {
            if (isLoading == true) {
              showLoading(context);
            } else {
              hideLoading(context);
            }
          });

          presenter?.isSessionExpiredStream.listen((isExpired) {
            if (isExpired == true) {
              Get.offAllNamed('/login');
            }
          });

          presenter?.loadData();

          return StreamBuilder<SurveyResultViewModel>(
            stream: presenter?.surveyResultStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ReloadScreen(
                  error: snapshot.error.toString(),
                  reload: presenter?.loadData,
                );
              }

              if (snapshot.hasData) {
                return SurveyResult(viewModel: snapshot.data!);
              }
              return const SizedBox(height: 0);
            },
          );
        },
      ),
    );
  }
}
