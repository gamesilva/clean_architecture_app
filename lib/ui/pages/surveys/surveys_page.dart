// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../components/components.dart';
import '../../helpers/helpers.dart';

import 'components/components.dart';
import 'survey_viewmodel.dart';
import 'surveys_presenter.dart';

class SurveysPage extends StatelessWidget {
  final SurveysPresenter? presenter;

  SurveysPage({this.presenter});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.strings.surveys),
      ),
      body: Builder(builder: (context) {
        presenter?.isLoadingStream.listen((isLoading) {
          if (isLoading == true) {
            showLoading(context);
          } else {
            hideLoading(context);
          }
        });

        presenter?.loadData();

        return StreamBuilder<List<SurveyViewModel>?>(
          stream: presenter?.surveysStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ReloadScreen(
                error: snapshot.error.toString(),
                reload: presenter?.loadData,
              );
            }

            if (snapshot.hasData) {
              return SurveyItems(snapshot.data!);
            }

            return const SizedBox(height: 0);
          },
        );
      }),
    );
  }
}
