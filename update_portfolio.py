import re

with open('lib/screens/web/portfolio_screen.dart', 'r') as f:
    content = f.read()

# Replace instantiations
content = content.replace('_ExperienceCard', 'ExperienceCard')
content = content.replace('_EducationCard', 'EducationCard')
content = content.replace('_ProjectRow', 'ProjectRow')
content = content.replace('_ProjectCard', 'ProjectCard')

# Remove class definitions using regex (or roughly)
# class _ExperienceCard ... }
exp_pattern = re.compile(r'class ExperienceCard extends StatelessWidget \{.*?\n\}\n', re.DOTALL)
edu_pattern = re.compile(r'class EducationCard extends StatelessWidget \{.*?\n\}\n', re.DOTALL)
proj_row_pattern = re.compile(r'class ProjectRow extends StatefulWidget \{.*?\n\}\n\s*class _ProjectRowState extends State<ProjectRow> \{.*?\n\}\n', re.DOTALL)
proj_card_pattern = re.compile(r'class ProjectCard extends StatefulWidget \{.*?\n\}\n\s*class _ProjectCardState extends State<ProjectCard> \{.*?\n\}\n', re.DOTALL)

content = exp_pattern.sub('', content)
content = edu_pattern.sub('', content)
content = proj_row_pattern.sub('', content)
content = proj_card_pattern.sub('', content)

# Add imports
imports = """
import 'widgets/experience_card.dart';
import 'widgets/education_card.dart';
import 'widgets/project_row.dart';
import 'widgets/project_card.dart';
"""
content = content.replace("import '../../config.dart';", "import '../../config.dart';\n" + imports)

with open('lib/screens/web/portfolio_screen.dart', 'w') as f:
    f.write(content)
