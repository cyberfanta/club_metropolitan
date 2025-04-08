// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  // Execute the command directly on the system
  Process.run('git', [
    'log',
    'master',
    '--pretty=format:%ad:%B',
    '--date=format:%Y-%m-%d',
    '--no-merges'
  ]).then((result) {
    if (result.exitCode != 0) {
      print(
          'Error running git log. Make sure git is properly installed and configured.');
      print('Error details: ${result.stderr}');

      return;
    }

    // Process the logs obtained
    final logs = result.stdout
        .toString()
        .trim()
        .split('\n\n'); // Split by blank lines to get full messages

    if (logs.isEmpty) {
      print('No commits found on the "main" branch.');

      return;
    }

    // Group commits by month, excluding unwanted messages
    final Map<String, List<String>> groupedCommits = {};
    String? previousTitle; // Store the previous title for comparison

    for (var log in logs) {
      final parts = log.split(':');

      if (parts.length < 2) {
        continue; // Ensure there is at least a date and a title
      }

      final date = parts[0].trim(); // Extract the date
      final title = parts
          .sublist(1)
          .join(':')
          .trim(); // Extract the rest as the full title

      // Validate date format (YYYY-MM-DD)
      if (date.length < 10 || !RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(date)) {
        // print('Invalid date format found: "$date". Skipping commit.');
        continue;
      }

      // Exclude unwanted commits
      if (title.contains('Commit the artifact') ||
          title.contains('Deleting artifact')) {
        continue;
      }

      // Skip if the current title is the same as the previous one
      if (title == previousTitle) {
        continue;
      }

      previousTitle = title; // Update the previous title
      final monthKey = date.substring(0, 7); // Format YYYY-MM

      // Add the commit to the corresponding month
      groupedCommits.putIfAbsent(monthKey, () => []);
      groupedCommits[monthKey]!
          .add('**$date**: $title\n'); // Add a newline after each entry
    }

    // Create the changelog content
    final changelogBuffer = StringBuffer();

    changelogBuffer.writeln('# Changelog\n');
    changelogBuffer
        .writeln('To Generate this, run `dart run generate_changelog.dart`\n');
    changelogBuffer
        .writeln('This file contains a list of changes grouped by month.\n');

    // Sort months from most recent to oldest
    final sortedMonths = groupedCommits.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Reverse order (most recent first)

    for (var month in sortedMonths) {
      changelogBuffer.writeln('## $month\n');

      // Sort commits within each month from most recent to oldest
      final sortedCommits = groupedCommits[month]!
        ..sort((a, b) => b.compareTo(a)); // Reverse order within each month

      for (var commit in sortedCommits) {
        changelogBuffer.writeln(commit);
      }
    }

    // Overwrite the CHANGELOG.md file
    final changelogFile = File('CHANGELOG.md');

    changelogFile.writeAsStringSync(changelogBuffer.toString());

    print('The CHANGELOG.md file has been successfully generated.');
  });
}
