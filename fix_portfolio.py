import re

with open('lib/screens/web/portfolio_screen.dart', 'r') as f:
    content = f.read()

proj_row_pattern = re.compile(r'class ProjectRow extends StatefulWidget \{.*?\n\}\n\s*class ProjectRowState extends State<ProjectRow> \{.*?\n\}\n', re.DOTALL)
proj_card_pattern = re.compile(r'class ProjectCard extends StatefulWidget \{.*?\n\}\n\s*class ProjectCardState extends State<ProjectCard> \{.*?\n\}\n', re.DOTALL)

content = proj_row_pattern.sub('', content)
content = proj_card_pattern.sub('', content)

with open('lib/screens/web/portfolio_screen.dart', 'w') as f:
    f.write(content)
