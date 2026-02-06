import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lietucoach/features/common/services/asset_audio_resolver.dart';
import '../../design_system/glass/glass.dart';
import '../../srs/srs.dart';
import '../../ui/components/buttons.dart';
import '../../ui/tokens.dart';
import 'domain/role_model.dart';
import 'service/role_progress_service.dart';

class RoleTakeawaysScreen extends StatefulWidget {
  final RoleDialogue dialogue;
  final RolePack pack;
  final VoidCallback onFinish;

  const RoleTakeawaysScreen({
    super.key,
    required this.dialogue,
    required this.pack,
    required this.onFinish,
  });

  @override
  State<RoleTakeawaysScreen> createState() => _RoleTakeawaysScreenState();
}

class _RoleTakeawaysScreenState extends State<RoleTakeawaysScreen> {
  final Set<int> _selectedIndices = {};
  final Map<int, bool> _audioAvailableByIndex = {};
  final AudioPlayer _player = AudioPlayer();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.dialogue.takeaways.length; i++) {
      _selectedIndices.add(i);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _probeTakeawayAudio();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _onToggle(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIndices
        ..clear()
        ..addAll(
          List<int>.generate(widget.dialogue.takeaways.length, (i) => i),
        );
    });
  }

  void _clearAll() {
    setState(() {
      _selectedIndices.clear();
    });
  }

  Future<void> _probeTakeawayAudio() async {
    final bundle = DefaultAssetBundle.of(context);
    await assetAudioResolver.ensureInitialized(bundle);
    final paths = widget.dialogue.takeaways
        .map((item) => item.audioNormalPath)
        .toList(growable: false);
    final availability = await assetAudioResolver.existsMany(
      paths,
      bundle: bundle,
    );
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < availability.length; i++) {
        _audioAvailableByIndex[i] = availability[i];
      }
    });
  }

  Future<void> _playPhraseAudio(int index, RolePhraseCard item) async {
    final hasAudio = _audioAvailableByIndex[index] ?? true;
    if (!hasAudio) return;
    try {
      await _player.stop();
      await _player.setAsset(item.audioNormalPath);
      await _player.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio missing for this phrase.'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _onFinish() async {
    setState(() => _isSaving = true);

    final cardsToSave = <SrsCard>[];
    for (final index in _selectedIndices) {
      final phrase = widget.dialogue.takeaways[index];
      final safePhrase = phrase.lt
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), '_')
          .replaceAll(RegExp(r'_+'), '_');
      final phraseId = safePhrase.length > 30
          ? safePhrase.substring(0, 30)
          : safePhrase;
      final unitId = widget.pack.id;
      final cardId = SrsCard.createId('roles', unitId, phraseId);

      cardsToSave.add(
        SrsCard(
          cardId: cardId,
          unitId: unitId,
          phraseId: phraseId,
          front: phrase.lt,
          back: phrase.en,
          audioId: phrase.audioNormalPath,
          reps: 0,
          lapses: 0,
        ),
      );
    }

    try {
      if (cardsToSave.isNotEmpty) {
        await srsStore.upsertCards(cardsToSave);
      }
      await roleProgressService.markDialogueComplete(widget.dialogue.id);
      if (mounted) {
        widget.onFinish();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving progress: $e')));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final takeaways = widget.dialogue.takeaways;
    final cardRadius = BorderRadius.circular(AppSemanticShape.radiusCard);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Takeaways'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(Spacing.pagePadding),
              children: [
                Text(
                  'Key Phrases',
                  style: AppSemanticTypography.section.copyWith(
                    color: semantic.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSemanticSpacing.space8),
                Text(
                  'Select phrases to add to your daily review.',
                  style: AppSemanticTypography.body.copyWith(
                    color: semantic.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSemanticSpacing.space8),
                Row(
                  children: [
                    Text(
                      '${_selectedIndices.length} selected',
                      style: AppSemanticTypography.caption.copyWith(
                        color: semantic.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _selectAll,
                      child: const Text('Select all'),
                    ),
                    const SizedBox(width: AppSemanticSpacing.space8),
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSemanticSpacing.space8),
                ...List.generate(takeaways.length, (index) {
                  final item = takeaways[index];
                  final isSelected = _selectedIndices.contains(index);
                  final hasAudio = _audioAvailableByIndex[index] ?? true;

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSemanticSpacing.space12,
                    ),
                    child: GlassSurface(
                      preset: GlassPreset.solid,
                      borderRadius: cardRadius,
                      overlayOpacity: isSelected ? 0.12 : null,
                      border: Border.all(
                        color: isSelected
                            ? semantic.accentPrimary
                            : semantic.borderSubtle,
                        width: isSelected ? 1.8 : 1,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onToggle(index),
                          customBorder: RoundedRectangleBorder(
                            borderRadius: cardRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppSemanticSpacing.space12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.lt,
                                        style: AppSemanticTypography.body
                                            .copyWith(
                                              color: semantic.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: AppSemanticSpacing.space4,
                                      ),
                                      Text(
                                        item.en,
                                        style: AppSemanticTypography.caption
                                            .copyWith(
                                              color: semantic.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: AppSemanticSpacing.space8,
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      size: 20,
                                      color: isSelected
                                          ? semantic.accentPrimary
                                          : semantic.textTertiary,
                                    ),
                                    const SizedBox(
                                      height: AppSemanticSpacing.space8,
                                    ),
                                    Opacity(
                                      opacity: hasAudio ? 1 : 0.5,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: hasAudio
                                              ? () => _playPhraseAudio(
                                                  index,
                                                  item,
                                                )
                                              : null,
                                          customBorder: const CircleBorder(),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: semantic.surfaceElevated,
                                              border: Border.all(
                                                color: semantic.borderSubtle,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.volume_up_rounded,
                                              size: 20,
                                              color: hasAudio
                                                  ? semantic.textPrimary
                                                  : semantic.textTertiary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(Spacing.pagePadding),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: semantic.shadowSoft,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: _isSaving ? 'SAVING...' : 'FINISH',
                isLoading: _isSaving,
                isFullWidth: true,
                onPressed: _onFinish,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
