import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../helpers/helpers.dart';
import '../../mixins/mixins.dart';

import 'survey_result.dart';

class SurveyResultPage extends StatelessWidget
    with LoadingManager, SessionManager {
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
          handleLoading(context, presenter?.isLoadingStream);
          handleSessionExpired(presenter?.isSessionExpiredStream);
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
