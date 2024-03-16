import 'package:stashmobile/models/chat.dart';


final defaultPrompts = [
  Prompt(
      name: 'Why', 
      text: 'Can you delve deeper into why this is the case and the underlying factors?',
      symbol: '❓'
  ),
  Prompt(
      name: 'Root', 
      text: 'Apply the "5 Whys" technique to uncover the root cause behind this.',
      symbol: '🌱'
  ),
  Prompt(
      name: 'Validate', 
      text: 'How credible are the propositions in this text, and what evidence supports them?',
      symbol: '✅'
  ),
  Prompt(
      name: 'Broaden', 
      text: 'What broader implications or related aspects does this text overlook?',
      symbol: '🔍'
  ),
  Prompt(
      name: 'Narrow', 
      text: 'Identify and elaborate on the single most critical point made in this text.',
      symbol: '🎯'
  ),
  Prompt(
      name: 'Answer', 
      text: 'What are the comprehensive answers to the questions raised in this text?',
      symbol: '💡'
  ),
  Prompt(
      name: 'Questions', 
      text: 'What additional questions arise from the discussion in this text?',
      symbol: '❔'
  ),
  Prompt(
      name: 'Rhyme', 
      text: 'Creatively rewrite this text as a rhyming poem, maintaining its original essence.',
      symbol: '📝'
  ),
  Prompt(
      name: 'Application', 
      text: 'Explore the real-world applications or implications of the concepts discussed in this text.',
      symbol: '🔧'
  ),
  Prompt(
      name: 'Simplify', 
      text: 'Simplify the explanation of this text, making it accessible to a younger audience.',
      symbol: '👶'
  ),
  Prompt(
      name: 'Contrast', 
      text: 'How does this viewpoint differ from other perspectives on the same issue?',
      symbol: '⚖️'
  ),
  Prompt(
      name: 'SWOT', 
      text: 'Conduct a SWOT analysis (Strengths, Weaknesses, Opportunities, Threats) of the ideas presented.',
      symbol: '💼'
  ),
  Prompt(
      name: 'History', 
      text: 'Which historical contexts or figures significantly impact the subject of this text?',
      symbol: '🕰️'
  ),
  Prompt(
      name: 'Evolution', 
      text: 'Trace the evolution of the central idea of this text through time.',
      symbol: '📈'
  ),
  Prompt(
      name: 'Related', 
      text: 'What topics are closely related to this discussion, and how do they interconnect?',
      symbol: '🔗'
  ),
  Prompt(
      name: 'Future', 
      text: 'Discuss the potential future developments and trends stemming from the topic of this text.',
      symbol: '🔮'
  )
      
];