import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';

class InsightDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;

  const InsightDetailScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final articleData = _getArticleContent(title);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.heading),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Maxillofacial Insight',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.heading,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge & Reading Time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: AppColors.primaryBlue),
                      const SizedBox(width: 6),
                      Text(
                        articleData.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time_rounded, size: 14, color: AppColors.subText),
                const SizedBox(width: 4),
                Text(
                  articleData.readTime,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.subText),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.heading,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle summary
            Text(
              articleData.summary,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.subText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Hero Highlight Box
            SoftCard(
              color: AppColors.blueBg,
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clinical Key Takeaway',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          articleData.keyTakeaway,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Article Sections
            ...articleData.sections.map((section) => _buildSection(section)),

            const SizedBox(height: 16),

            // Medical Disclaimer Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Medical Disclaimer: The information provided in MaxilloAI insights is for educational purposes and AI prediction guidance. Always consult your attending oral and maxillofacial surgeon for individualized medical decisions.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Back Button
            Center(
              child: SmallButton(
                label: 'Back to Dashboard',
                icon: Icons.arrow_back_rounded,
                isOutlined: true,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(_ArticleSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
          if (section.bulletPoints != null && section.bulletPoints!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...section.bulletPoints!.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.tealDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.darkText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _ArticleData _getArticleContent(String title) {
    if (title.contains('Understanding Maxillofacial')) {
      return _ArticleData(
        category: 'Surgical Overview',
        readTime: '4 min read',
        summary:
            'Learn how modern computer-assisted surgical planning and AI reconstruction models restore complex facial structures, jawbones, and soft tissue contour.',
        keyTakeaway:
            'Patient-specific 3D modeling allows surgeons to pre-plan graft placement with sub-millimeter precision before entering the operating room.',
        sections: [
          _ArticleSection(
            heading: 'What is Maxillofacial Reconstruction?',
            body:
                'Maxillofacial reconstruction is a specialized surgical discipline dedicated to restoring anatomical form and essential physiological function—such as chewing, swallowing, speech, and facial symmetry—following trauma, tumor resection, or congenital conditions.',
            bulletPoints: [
              'Pre-operative 3D CT scan mapping of facial skeletal framework',
              'Custom surgical cutting guides tailored to unique patient anatomy',
              'Free tissue transfer using bone and microvascular blood supply from donor sites',
            ],
          ),
          _ArticleSection(
            heading: 'The Role of AI & Virtual Surgical Planning',
            body:
                'With MaxilloAI, advanced deep learning models compare patient CT/MRI imaging against healthy anatomical datasets. The AI computes optimal graft angles, predicts tissue expansion, and estimates healing trajectories with over 90% confidence.',
          ),
          _ArticleSection(
            heading: 'What to Expect During Rehabilitation',
            body:
                'Reconstruction is a multi-phase journey. Over 3 to 12 months, bone integration occurs alongside soft tissue maturation, progressive scar settling, and facial tension adaptation.',
          ),
        ],
      );
    } else if (title.contains('Recovery Guidelines') || title.contains('Post-Operative')) {
      return _ArticleData(
        category: 'Patient Care',
        readTime: '5 min read',
        summary:
            'A comprehensive guide to managing your healing journey step-by-step from hospital discharge through long-term facial adaptation.',
        keyTakeaway:
            'Strict adherence to wound hygiene, prescribed head elevation, and soft diet protocols dramatically reduces complications and speeds recovery.',
        sections: [
          _ArticleSection(
            heading: 'Phase 1: Days 1–14 (Acute Postsurgical Care)',
            body:
                'The initial two weeks focus on minimizing edema (swelling), protecting suture lines, and ensuring microvascular flap perfusion.',
            bulletPoints: [
              'Sleep with head elevated at 30–45 degrees to encourage lymphatic drainage',
              'Avoid strenuous activity, bending, or heavy lifting (>5 lbs)',
              'Follow oral rinse protocols using prescribed chlorhexidine or saline after meals',
              'Maintain a full liquid to ultra-soft diet as directed by your care team',
            ],
          ),
          _ArticleSection(
            heading: 'Phase 2: Weeks 3–8 (Tissue Settlement & Mobility)',
            body:
                'Swelling begins to recede significantly. Gentle jaw movement exercises may be introduced to prevent trismus (jaw stiffness).',
          ),
          _ArticleSection(
            heading: 'When to Call Your Surgeon Immediately',
            body:
                'Contact your clinical team right away if you notice sudden increased swelling, redness, fever above 101°F (38.3°C), dark color changes at graft sites, or persistent fluid drainage.',
          ),
        ],
      );
    } else if (title.contains('AI Prediction') || title.contains('FAQs')) {
      return _ArticleData(
        category: 'AI Technology',
        readTime: '3 min read',
        summary:
            'Answers to common questions regarding how MaxilloAI analyzes medical scans, calculates confidence scores, and protects your medical data privacy.',
        keyTakeaway:
            'MaxilloAI algorithms are trained on verified clinical datasets to assist surgeons with objective risk scoring and milestone tracking.',
        sections: [
          _ArticleSection(
            heading: 'How does MaxilloAI predict surgical outcomes?',
            body:
                'The platform utilizes deep neural networks trained on thousands of maxillofacial cases. It processes clinical inputs—such as defect dimensions, patient age, resection site, and comorbidities—to model recovery estimates and risk stratification.',
          ),
          _ArticleSection(
            heading: 'What does the Confidence Score mean?',
            body:
                'The confidence score reflects statistical alignment with historical clinical outcomes. A score of 90%+ indicates high data similarity to proven successful reconstructive trajectories.',
            bulletPoints: [
              '90%+: High alignment with standard successful recovery paths',
              '75–89%: Good alignment with standard post-op monitoring recommended',
              'Below 75%: Requires customized clinical oversight and extended observation',
            ],
          ),
          _ArticleSection(
            heading: 'Is my data secure?',
            body:
                'Yes. All patient imaging and personal health information are encrypted end-to-end using AES-256 standards in compliance with healthcare data regulations.',
          ),
        ],
      );
    } else {
      return _ArticleData(
        category: 'Surgical Techniques',
        readTime: '4 min read',
        summary:
            'An in-depth look at microvascular free flap transfer, vascular anastomosis, and anatomical donor site healing.',
        keyTakeaway:
            'Microvascular free tissue transfer provides its own blood supply, enabling robust tissue integration even in complex reconstructive sites.',
        sections: [
          _ArticleSection(
            heading: 'Understanding Microvascular Free Flaps',
            body:
                'A microvascular flap involves transplanting living tissue—such as bone, muscle, or skin—along with its primary artery and vein to the reconstructive site. Under a microscope, surgeons connect these blood vessels to native vessels in the neck.',
            bulletPoints: [
              'Fibula Free Flap: Provides long segments of dense bone ideal for mandibular (lower jaw) reconstruction',
              'Radial Forearm Flap: Offers thin, pliable soft tissue for palatal or tongue reconstruction',
              'Anterolateral Thigh (ALT) Flap: Delivers versatile volume for large tissue defects',
            ],
          ),
          _ArticleSection(
            heading: 'Monitoring Flap Perfusion & Viability',
            body:
                'In the early post-op window, clinical staff monitor flap temperature, capillary refill, and doppler acoustic signals every 1 to 2 hours to confirm robust blood circulation.',
          ),
          _ArticleSection(
            heading: 'Long-term Integration',
            body:
                'Over 6 to 12 months, neovascularization (new blood vessel growth) connects the transferred graft seamlessly into surrounding facial structures.',
          ),
        ],
      );
    }
  }
}

class _ArticleData {
  final String category;
  final String readTime;
  final String summary;
  final String keyTakeaway;
  final List<_ArticleSection> sections;

  _ArticleData({
    required this.category,
    required this.readTime,
    required this.summary,
    required this.keyTakeaway,
    required this.sections,
  });
}

class _ArticleSection {
  final String heading;
  final String body;
  final List<String>? bulletPoints;

  _ArticleSection({
    required this.heading,
    required this.body,
    this.bulletPoints,
  });
}
