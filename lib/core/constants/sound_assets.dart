class SoundAssets {
  // NOTE: SFX files below may have variants in assets/audio/sfx/
  // Music files are static and do not use variants.
  // The AudioService automatically appends the suffix for SFX based on user settings.

  // --- Music ---
  static const String mainAmbience = 'main_bgm.mp3';
  static const String appBgm = 'main_bgm.mp3';

  // --- SFX: Core Interactions ---
  static const String cardFlip = 'card_flip.wav';
  static const String cardSlide = 'card_slide.wav';
  static const String chipPlace = 'chip_place.wav';
  static const String dealCard = 'deal_card.wav';

  // --- SFX: Actions ---
  static const String buttonTap = 'button_tap.wav';
  static const String toggleOn = 'toggle_on.wav';
  static const String toggleOff = 'toggle_off.wav';
  static const String error = 'error.wav';
  static const String success = 'success.wav';

  // --- SFX: Notifications ---
  static const String turnAlert = 'turn_alert.wav';
  static const String challenge = 'challenge.wav';
  static const String winRound = 'win_round.wav';
  static const String loseRound = 'lose_round.wav';
  static const String bluffCaught = 'bluff_caught.wav';
}
