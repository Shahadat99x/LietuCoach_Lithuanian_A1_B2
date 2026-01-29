# Content Authoring Guide

> **AI CONTRACT**
> This guide defines content authoring rules.
> All content must comply with these constraints.
> Step types here must match docs/CONTENT_SCHEMA.json exactly.

## ID Rules

### phraseId
- Pattern: lowercase snake_case (e.g., `hello`, `good_morning`)
- Unique within a unit
- Used to reference items in the unit's `items` dictionary

### audioId
- Pattern: lowercase snake_case (e.g., `a1_u01_hello`, `a1_u01_good_morning`)
- Unique within a unit
- Maps to audio file path (see Audio Rules)
- NOT the same as phraseId; audioId includes level/unit prefix for global uniqueness

### Lesson ID
- Recommended format: `lesson_NN_topic` (e.g., `lesson_01_greetings`, `lesson_02_farewells`)
- Unique within a unit
- Avoid numeric-only IDs

## A1 Level Constraints

### Lesson Size
- **New items per lesson**: 3-6 (vocabulary or phrases)
- **Core steps per lesson**: 6-10 (excludes `lesson_complete`)
- **`lesson_complete` step**: Optional, not counted as a core step
- **Lesson duration target**: 3-5 minutes

### Language Complexity
- Short sentences (5-10 words max)
- Present tense primarily
- Conservative grammar (no complex cases early)
- High-frequency vocabulary only
- Clear, unambiguous translations

### Translation Consistency
- Same Lithuanian word = same English translation throughout course
- Avoid synonyms in translations until B1
- Include gender/formality notes where relevant

## Step Types

| Type | Description | Required Fields |
|------|-------------|-----------------|
| `teach_phrase` | Introduce new phrase with audio | `phraseId`, `showTranslation` |
| `mcq` | Multiple choice question | `prompt`, `options`, `correctIndex` |
| `match` | Match pairs (L1-L2) | `pairs` |
| `reorder` | Arrange words in order | `words`, `correctOrder` |
| `fill_blank` | Complete the sentence | `sentence`, `blank`, `answer` |
| `listening_choice` | Listen and choose correct text | `audioId`, `options`, `correctIndex` |
| `dialogue_choice` | Choose response in dialogue | `context`, `options`, `correctIndex` |
| `lesson_complete` | End screen with summary | `itemsLearned`, `xpEarned` |

## Exam and Gating Rules

### Unit Exams (MVP)
- **Auto-generated** from unit items (no manual authoring required)
- Required to unlock next unit
- Tests all items from unit
- Passing score: 80%
- Can retry immediately

### Checkpoint Exams (Post-MVP)
- Required at level transitions (A1 -> A2)
- Comprehensive review of level content
- Passing score: 85%
- Cooldown between retries: 24 hours
- TODO: Implement after MVP

### Gating Logic
```
Unit N+1 locked until:
  - All lessons in Unit N completed
  - Unit N exam passed (>=80%)
```

## Role Packs

Role packs are optional thematic content bundles:

| Role | Description | Unlock Condition |
|------|-------------|------------------|
| `traveler` | Airport, hotel, directions | After A1 Unit 2 |
| `food_delivery` | Ordering, addresses, payments | After A1 Unit 3 |
| `student` | University, schedules, registration | After A1 Unit 4 |
| `worker` | Workplace basics, introductions | After A1 Unit 5 |

Role packs:
- Use vocabulary already learned + role-specific additions
- Self-contained (3-5 lessons each)
- Optional but recommended for practical application

## Audio Rules

### File Naming
File path derived from audioId:
```
audio/{level}/{unit}/{audioId}_{variant}.ogg

Example:
audioId: "a1_u01_hello"
-> audio/a1/unit01/a1_u01_hello_normal.ogg
-> audio/a1/unit01/a1_u01_hello_slow.ogg (optional)
```

### Variants
- `normal`: Standard speaking pace (REQUIRED)
- `slow`: 0.7x speed for learners (OPTIONAL in MVP)

### Requirements
- Format: OGG Vorbis (speech-optimized, smaller files)
- Quality: q5 (~128kbps equivalent)
- Sample rate: 44.1kHz
- Silence: Max 200ms padding
- Normalization: -16 LUFS

### Audio ID Reference
In unit JSON, items reference audio by audioId:
```json
{
  "items": {
    "hello": {
      "lt": "Labas",
      "en": "Hello",
      "audioId": "a1_u01_hello"
    }
  }
}
```
Audio provider resolves `a1_u01_hello` to: `audio/a1/unit01/a1_u01_hello_normal.ogg`
