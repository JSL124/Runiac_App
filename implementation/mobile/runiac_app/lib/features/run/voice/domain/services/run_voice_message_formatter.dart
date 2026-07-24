import '../models/run_voice_announcement.dart';
import '../models/run_voice_language.dart';
import '../models/run_voice_session_config.dart';

abstract interface class RunVoiceMessageFormatter {
  String format(RunVoiceAnnouncement announcement, RunVoiceSessionConfig config);
}

/// Localizes every [RunVoiceAnnouncementType] into an EN/KO/ZH sentence,
/// optionally appending an elapsed-time clause and/or an average-pace
/// clause per [RunVoiceSessionConfig.includeElapsedTime] and
/// [RunVoiceSessionConfig.includeAveragePace].
///
/// Time milestones are the one exception to the elapsed-time flag: the
/// elapsed minutes are the substance of the message itself, so they are
/// always stated regardless of [RunVoiceSessionConfig.includeElapsedTime].
class LocalizedRunVoiceMessageFormatter implements RunVoiceMessageFormatter {
  const LocalizedRunVoiceMessageFormatter();

  @override
  String format(
    RunVoiceAnnouncement announcement,
    RunVoiceSessionConfig config,
  ) {
    switch (announcement.type) {
      case RunVoiceAnnouncementType.distanceMilestone:
        return _formatDistanceMilestone(announcement, config);
      case RunVoiceAnnouncementType.timeMilestone:
        return _formatTimeMilestone(announcement, config);
      case RunVoiceAnnouncementType.targetHalfway:
        return _formatTargetHalfway(announcement, config);
      case RunVoiceAnnouncementType.targetCompleted:
        return _formatTargetCompleted(announcement, config);
    }
  }

  String _formatDistanceMilestone(
    RunVoiceAnnouncement announcement,
    RunVoiceSessionConfig config,
  ) {
    final km = _km(announcement.distanceMeters ?? 0);
    final elapsed = announcement.elapsed;
    final pace = announcement.averagePace;
    final includeElapsed = config.includeElapsedTime;
    final includePace = config.includeAveragePace && pace != null;

    switch (config.language) {
      case RunVoiceLanguage.english:
        final buffer = StringBuffer(
          'You have completed $km kilometer${km == '1' ? '' : 's'}.',
        );
        if (includeElapsed) {
          buffer.write(' Your time is ${_durEn(elapsed)}.');
        }
        if (includePace) {
          buffer.write(' Your average pace is ${_durEn(pace)} per kilometer.');
        }
        return buffer.toString();
      case RunVoiceLanguage.korean:
        final buffer = StringBuffer('$km킬로미터를 완료했습니다.');
        if (includeElapsed) {
          buffer.write(' 운동 시간은 ${_durKo(elapsed)}입니다.');
        }
        if (includePace) {
          buffer.write(' 평균 페이스는 킬로미터당 ${_durKo(pace)}입니다.');
        }
        return buffer.toString();
      case RunVoiceLanguage.simplifiedChinese:
        final buffer = StringBuffer('您已完成$km公里。');
        if (includeElapsed) {
          buffer.write('运动时间${_durZh(elapsed)}。');
        }
        if (includePace) {
          buffer.write('平均配速每公里${_durZh(pace)}。');
        }
        return buffer.toString();
    }
  }

  String _formatTimeMilestone(
    RunVoiceAnnouncement announcement,
    RunVoiceSessionConfig config,
  ) {
    final minutes = announcement.elapsed.inMinutes;
    final pace = announcement.averagePace;
    final includePace = config.includeAveragePace && pace != null;

    switch (config.language) {
      case RunVoiceLanguage.english:
        final buffer = StringBuffer('$minutes minutes elapsed.');
        if (includePace) {
          buffer.write(' Your average pace is ${_durEn(pace)} per kilometer.');
        }
        return buffer.toString();
      case RunVoiceLanguage.korean:
        final buffer = StringBuffer('$minutes분 경과했습니다.');
        if (includePace) {
          buffer.write(' 평균 페이스는 킬로미터당 ${_durKo(pace)}입니다.');
        }
        return buffer.toString();
      case RunVoiceLanguage.simplifiedChinese:
        final buffer = StringBuffer('已经过$minutes分钟。');
        if (includePace) {
          buffer.write('平均配速每公里${_durZh(pace)}。');
        }
        return buffer.toString();
    }
  }

  String _formatTargetHalfway(
    RunVoiceAnnouncement announcement,
    RunVoiceSessionConfig config,
  ) {
    final elapsed = announcement.elapsed;
    final pace = announcement.averagePace;
    final includeElapsed = config.includeElapsedTime;
    final includePace = config.includeAveragePace && pace != null;

    switch (config.language) {
      case RunVoiceLanguage.english:
        final buffer = StringBuffer('You are halfway to your goal.');
        if (includeElapsed) {
          buffer.write(' Your time is ${_durEn(elapsed)}.');
        }
        if (includePace) {
          buffer.write(' Your average pace is ${_durEn(pace)} per kilometer.');
        }
        return buffer.toString();
      case RunVoiceLanguage.korean:
        final buffer = StringBuffer('목표 거리의 절반을 지났습니다.');
        if (includeElapsed) {
          buffer.write(' 운동 시간은 ${_durKo(elapsed)}입니다.');
        }
        if (includePace) {
          buffer.write(' 평균 페이스는 킬로미터당 ${_durKo(pace)}입니다.');
        }
        return buffer.toString();
      case RunVoiceLanguage.simplifiedChinese:
        final buffer = StringBuffer('您已到达目标距离的一半。');
        if (includeElapsed) {
          buffer.write('运动时间${_durZh(elapsed)}。');
        }
        if (includePace) {
          buffer.write('平均配速每公里${_durZh(pace)}。');
        }
        return buffer.toString();
    }
  }

  String _formatTargetCompleted(
    RunVoiceAnnouncement announcement,
    RunVoiceSessionConfig config,
  ) {
    final elapsed = announcement.elapsed;
    final pace = announcement.averagePace;
    final includeElapsed = config.includeElapsedTime;
    final includePace = config.includeAveragePace && pace != null;

    switch (config.language) {
      case RunVoiceLanguage.english:
        final buffer = StringBuffer(
          'You have reached your goal distance. Well done.',
        );
        if (includeElapsed) {
          buffer.write(' Your time is ${_durEn(elapsed)}.');
        }
        if (includePace) {
          buffer.write(' Your average pace is ${_durEn(pace)} per kilometer.');
        }
        return buffer.toString();
      case RunVoiceLanguage.korean:
        final buffer = StringBuffer('목표 거리를 완료했습니다. 수고하셨습니다.');
        if (includeElapsed) {
          buffer.write(' 운동 시간은 ${_durKo(elapsed)}입니다.');
        }
        if (includePace) {
          buffer.write(' 평균 페이스는 킬로미터당 ${_durKo(pace)}입니다.');
        }
        return buffer.toString();
      case RunVoiceLanguage.simplifiedChinese:
        final buffer = StringBuffer('您已完成目标距离。做得好。');
        if (includeElapsed) {
          buffer.write('运动时间${_durZh(elapsed)}。');
        }
        if (includePace) {
          buffer.write('平均配速每公里${_durZh(pace)}。');
        }
        return buffer.toString();
    }
  }

  String _km(int meters) {
    final value = meters / 1000;
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _durKo(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m > 0 && s > 0) {
      return '$m분 $s초';
    }
    if (m > 0) {
      return '$m분';
    }
    return '$s초';
  }

  String _durEn(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    final pieces = <String>[];
    if (m > 0) {
      pieces.add('$m minute${m == 1 ? '' : 's'}');
    }
    if (s > 0) {
      pieces.add('$s second${s == 1 ? '' : 's'}');
    }
    if (pieces.isEmpty) {
      return '0 seconds';
    }
    return pieces.join(' ');
  }

  String _durZh(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m > 0 && s > 0) {
      return '$m分$s秒';
    }
    if (m > 0) {
      return '$m分';
    }
    return '$s秒';
  }
}
