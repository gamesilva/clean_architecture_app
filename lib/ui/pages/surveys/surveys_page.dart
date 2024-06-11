// ignore_for_file: deprecated_member_use

import 'package:carousel_slider/carousel_slider.dart';
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
    presenter?.loadData();
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
        return StreamBuilder<List<SurveyViewModel>>(
          stream: presenter?.surveysStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Column(
                children: [
                  Text(snapshot.error.toString()),
                  RaisedButton(
                    child: Text(R.strings.reload),
                    onPressed: presenter?.loadData,
                  )
                ],
              );
            }

            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CarouselSlider(
                  items: snapshot.data!
                      .map((viewModel) => SurveyItem(viewModel))
                      .toList(),
                  options: CarouselOptions(
                    enlargeCenterPage: true,
                    aspectRatio: 1,
                  ),
                ),
              );
            }

            return const SizedBox(height: 0);
          },
        );
      }),
    );
  }
}