double freeInterpolate(double value, double minVal, double maxVal,
    double minReturn, double maxReturn) {
  if (value <= minVal) {
    return minReturn;
  }

  if (value >= maxVal) {
    return maxReturn;
  }

  return minReturn +
      (value - minVal) * (maxReturn - minReturn) / (maxVal - minVal);
}

double linearInterpolate(double value, double minVal, double maxVal) {
  return freeInterpolate(value, minVal, maxVal, 0, 1);
}
