import 'package:flutter/material.dart';
import '../../../data/models/job_vacancy_model.dart';
import '../../../data/models/job_application_model.dart';
import '../../../data/repositories/job_vacancy_repository.dart';

class JobVacancyViewModel extends ChangeNotifier {
  final JobVacancyRepository _repository = JobVacancyRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<JobVacancyModel> _openVacancies = [];
  List<JobVacancyModel> get openVacancies => _openVacancies;

  List<JobVacancyModel> _myPostedJobs = [];
  List<JobVacancyModel> get myPostedJobs => _myPostedJobs;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> loadOpenVacancies({String? category}) async {
    _setLoading(true);
    try {
      _openVacancies = await _repository.getOpenJobVacancies(
        category: category,
      );
    } catch (e) {
      debugPrint("Error loading open vacancies: \$e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserPostedJobs(String userId) async {
    _setLoading(true);
    try {
      _myPostedJobs = await _repository.getUserJobVacancies(userId);
    } catch (e) {
      debugPrint("Error loading user jobs: \$e");
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> postJobVacancy(JobVacancyModel vacancy) async {
    _setLoading(true);
    try {
      final newJob = await _repository.createJobVacancy(vacancy);
      _myPostedJobs.insert(0, newJob);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint("Error posting job: \$e");
      _setLoading(false);
      return false;
    }
  }

  Future<bool> applyToJob(JobApplicationModel application) async {
    _setLoading(true);
    try {
      await _repository.applyToJob(application);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint("Error applying to job: \$e");
      _setLoading(false);
      return false;
    }
  }
}
