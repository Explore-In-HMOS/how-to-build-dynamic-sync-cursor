export interface MarqueeSyncProfile {
  name: string;
  stepVp: number;
  loop: number;
  fromStart: boolean;
  pauseWhenPaused: boolean;
  animationRange: ExpectedFrameRateRange;
}

export class MarqueeSyncPresets {
  static smooth(): MarqueeSyncProfile {
    return MarqueeSyncPresets.normalize({
      name: 'Smooth',
      stepVp: 4,
      loop: -1,
      fromStart: false,
      pauseWhenPaused: true,
      animationRange: { min: 30, max: 90, expected: 60 }
    });
  }

  static brisk(): MarqueeSyncProfile {
    return MarqueeSyncPresets.normalize({
      name: 'Brisk',
      stepVp: 7,
      loop: -1,
      fromStart: false,
      pauseWhenPaused: true,
      animationRange: { min: 60, max: 120, expected: 90 }
    });
  }

  static economy(): MarqueeSyncProfile {
    return MarqueeSyncPresets.normalize({
      name: 'Economy',
      stepVp: 3,
      loop: -1,
      fromStart: true,
      pauseWhenPaused: true,
      animationRange: { min: 15, max: 45, expected: 30 }
    });
  }

  static normalize(profile: MarqueeSyncProfile): MarqueeSyncProfile {
    if (profile.pauseWhenPaused && profile.loop > 0) {
      profile.loop = -1;
    }
    return profile;
  }
}
