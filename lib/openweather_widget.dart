library servesook_weather_widget;

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'Config/Config.dart';
import 'actions/ActionWeather.dart';
import 'components/Skeleton.dart';
import 'models/WeatherForcast.dart';

class WeatherWidgets extends StatefulWidget {
  final String openWeatherApiKey;
  final double lat;
  final double lng;
  final int interval_ms;
  const WeatherWidgets({
    Key? key,
    required this.openWeatherApiKey,
    required this.lat,
    required this.lng,
    this.interval_ms = 5000,
  }) : super(key: key);

  @override
  _WeatherWidgetsState createState() => _WeatherWidgetsState();
}

class _WeatherWidgetsState extends State<WeatherWidgets> {
  final String iconSize = "4x";
  late Timer interval;
  late WeatherForcast weatherData;
  DateTime _dateTime = DateTime.now();
  bool isLoad = true;

  initialAction() async {
    final res = await ActionWeather.getOpenWeatherData(
        apiKey: widget.openWeatherApiKey, lat: widget.lat, lng: widget.lng);
    setState(() {
      weatherData = res;
      isLoad = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initialAction();
    interval = Timer.periodic(Duration(milliseconds: widget.interval_ms),
        (timer) async {
      final res = await ActionWeather.getOpenWeatherData(
          apiKey: widget.openWeatherApiKey, lat: widget.lat, lng: widget.lng);
      setState(() {
        weatherData = res;
      });
    });
  }

  @override
  void dispose() {
    interval.cancel();
    super.dispose();
  }

  String weekdayFomatter(DateTime _dateTime) {
    List<String> weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    return weekdays[_dateTime.weekday - 1];
  }

  String dateFomatter(DateTime _dateTime) {
    List<String> months = [
      "January",
      "Febuary",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${months[_dateTime.month - 1]} ${_dateTime.day} ${_dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return isLoad
        ? Skeleton(
            child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ))
        : Container(
            decoration: BoxDecoration(
              gradient:
                  ActionWeather.getWeatherGradient(weatherData.weather[0].id),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            child: CachedNetworkImage(
                                imageUrl:
                                    "${Config.weather_icon}${weatherData.weather[0].icon}@$iconSize.png"),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${weatherData.main.temp.toInt()} C˚",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "${weatherData.name},${weatherData.sys.country}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${weekdayFomatter(_dateTime)}",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Text(
                          "${dateFomatter(_dateTime)}",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
