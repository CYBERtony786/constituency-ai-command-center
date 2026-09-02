// File: lib/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'config.dart';

class GeminiService {
  // API key comes from config.dart (never hardcoded for GitHub safety)
  static const String _apiKey = AppConfig.geminiApiKey;

  late GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3.6-flash',
      apiKey: _apiKey,
    );
  }

  // ═════════════════════════════════════════════════════════
  // FUNCTION 1: Analyze a citizen complaint
  // ═════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> analyzeGrievance(
    String complaintText,
    String category,
    String location,
  ) async {
    try {
      final prompt = '''
You are an AI assistant helping an Indian Member of Parliament manage citizen grievances.

CITIZEN COMPLAINT:
Text: "$complaintText"
Category selected: $category
Location: $location

Analyze this grievance and return ONLY a JSON object (no markdown, no backticks) with this structure:

{
  "category": "The most accurate category from [roads, water, electricity, health, education, sanitation, street_lights, drainage, garbage, other]",
  "severity": "Choose from [low, medium, high, critical]",
  "sentiment": "Choose from [angry, frustrated, neutral, polite]",
  "affected_population": "Estimated number of people affected",
  "summary": "One-line summary in simple English",
  "suggested_actions": ["Action 1", "Action 2", "Action 3"],
  "responsible_department": "Which government department should handle this",
  "estimated_cost": "Rough cost in INR",
  "timeline": "Suggested resolution timeframe",
  "priority_score": "Number from 1-10 where 10 is most urgent",
  "tags": ["keyword1", "keyword2", "keyword3"]
}

Return ONLY valid JSON. No explanation, no markdown.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      String responseText = response.text ?? '{}';
      responseText =
          responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      return {
        'raw_analysis': responseText,
        'analyzed': true,
        'analyzed_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Gemini Error: $e');
      return {
        'error': e.toString(),
        'analyzed': false,
      };
    }
  }

  // ═════════════════════════════════════════════════════════
  // FUNCTION 2: Chat with AI about constituency
  // ═════════════════════════════════════════════════════════
  Future<String> chat(String question) async {
    try {
      final prompt = '''
You are an AI assistant helping an Indian Member of Parliament manage their constituency.

The MP asks: "$question"

Respond in a helpful, concise way. Use simple language.
If asked about data, provide realistic sample data.
If asked for advice, give practical, actionable suggestions.
Keep response under 200 words.
Use bullet points where helpful.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      return 'Error: $e\n\nPlease check your internet connection and try again.';
    }
  }

  // ═════════════════════════════════════════════════════════
  // FUNCTION 3: Generate resource allocation plan
  // ═════════════════════════════════════════════════════════
  Future<String> generateAllocationPlan(
    double budgetCrores,
    Map<String, int> grievanceCounts,
  ) async {
    try {
      final prompt = '''
You are an AI advisor helping an Indian MP allocate MPLADS budget.

BUDGET: ₹$budgetCrores Crores
CURRENT GRIEVANCE COUNTS BY CATEGORY:
${grievanceCounts.entries.map((e) => '${e.key}: ${e.value} complaints').join('\n')}

Create an optimal budget allocation plan that:
1. Prioritizes categories with most complaints
2. Follows MPLADS guidelines
3. Maximizes citizen impact
4. Includes at least 2 quick wins (projects completable in 3 months)

Format as a clear, readable plan with:
- Project name
- Budget allocation
- Expected beneficiaries
- Timeline
- Justification

Keep it practical and under 300 words.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Could not generate plan.';
    } catch (e) {
      return 'Error generating plan: $e';
    }
  }

  // ═════════════════════════════════════════════════════════
  // FUNCTION 4: Generate daily briefing
  // ═════════════════════════════════════════════════════════
  Future<String> generateDailyBriefing(
    int totalGrievances,
    int pending,
    int resolved,
    Map<String, int> categoryCounts,
  ) async {
    try {
      final prompt = '''
You are an AI assistant briefing an Indian MP on their constituency status.

TODAY'S DATA:
- Total Grievances: $totalGrievances
- Pending: $pending
- Resolved: $resolved
- Category Breakdown: ${categoryCounts.toString()}

Generate a brief morning briefing covering:
1. TOP PRIORITY: What needs immediate attention
2. SUMMARY: Key statistics
3. RECOMMENDATION: What the MP should focus on today
4. GOOD NEWS: Any positive developments

Keep it under 150 words. Use emojis for visual appeal.
Use simple language suitable for busy politicians.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Could not generate briefing.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ═════════════════════════════════════════════════════════
  // FUNCTION 5: Structured briefing for AI Workspace
  // ═════════════════════════════════════════════════════════
  Future<String> generateStructuredBriefing(
    String userQuestion, {
    required int totalGrievances,
    required int highPriority,
    required Map<String, int> categoryCounts,
    required String languageName,
  }) async {
    final prompt = '''
You are a senior policy advisor for an Indian Member of Parliament.
Respond in $languageName language only.

CONSTITUENCY DATA:
- Total grievances: $totalGrievances
- High priority grievances: $highPriority
- Category breakdown: ${categoryCounts.entries.map((e) => '${e.key}: ${e.value}').join(', ')}

MP asked: "$userQuestion"

Reply in this EXACT structured format (keep short, professional):

## Overview
[1-2 sentence direct answer to the question]

## Critical Issues
- [Issue 1]
- [Issue 2]
- [Issue 3 if relevant]

## Recommended Actions
- [Action 1 - specific and doable this week]
- [Action 2]
- [Action 3]

## Estimated Budget Impact
₹[amount in Lakhs or Crores] — [1 line reasoning]

Rules:
- No greeting, no emoji spam
- No markdown symbols other than ## and -
- Keep total response under 180 words
- Ground answers in the provided data
''';

    try {
      return await chat(prompt);
    } catch (e) {
      return 'Unable to generate briefing right now.';
    }
  }
}