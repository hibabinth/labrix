import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_vacancy_model.dart';
import '../models/job_application_model.dart';

class JobVacancyRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all open job vacancies for workers to browse
  Future<List<JobVacancyModel>> getOpenJobVacancies({String? category}) async {
    var query = _supabase.from('job_vacancies').select().eq('status', 'open');
    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((json) => JobVacancyModel.fromJson(json))
        .toList();
  }

  // Fetch jobs posted by a specific user
  Future<List<JobVacancyModel>> getUserJobVacancies(String userId) async {
    final response = await _supabase
        .from('job_vacancies')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((json) => JobVacancyModel.fromJson(json))
        .toList();
  }

  // Post a new job vacancy (User)
  Future<JobVacancyModel> createJobVacancy(JobVacancyModel vacancy) async {
    final data = vacancy.toJson();
    data.remove('id'); // let Supabase generate UUID
    data.remove('created_at');

    final response = await _supabase
        .from('job_vacancies')
        .insert(data)
        .select()
        .single();
    return JobVacancyModel.fromJson(response);
  }

  // Apply to a job (Worker)
  Future<JobApplicationModel> applyToJob(
    JobApplicationModel application,
  ) async {
    final data = application.toJson();
    data.remove('id');
    data.remove('created_at');

    final response = await _supabase
        .from('job_applications')
        .insert(data)
        .select()
        .single();
    return JobApplicationModel.fromJson(response);
  }
}
