import 'package:flutter/material.dart';

class RatingSlider extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double value;

  const RatingSlider({super.key, required this.onChanged, required this.value});

  @override
  _RatingSliderState createState() => _RatingSliderState();
}

class _RatingSliderState extends State<RatingSlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: widget.value,
      onChanged: (double newValue) {
        widget.onChanged(newValue);
      },
      min: 0.0,
      max: 5.0,
      divisions: 5,
      label: '${widget.value}',
    );
  }
}
