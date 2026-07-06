export enum SwiperPhysicsModel {
  SPRING = 0,
  RESPONSIVE_SPRING = 1,
  FRICTION = 2
}

export interface SwiperSyncProfile {
  name: string;
  model: SwiperPhysicsModel;
  response: number;
  damping: number;
  durationMs: number;
  gestureRange: ExpectedFrameRateRange;
  animationRange: ExpectedFrameRateRange;
}

export class SwiperSyncPresets {
  static spring(): SwiperSyncProfile {
    return {
      name: 'Spring',
      model: SwiperPhysicsModel.SPRING,
      response: 0.38,
      damping: 0.82,
      durationMs: 420,
      gestureRange: { min: 60, max: 120, expected: 120 },
      animationRange: { min: 30, max: 120, expected: 90 }
    };
  }

  static responsiveSpring(): SwiperSyncProfile {
    return {
      name: 'Responsive',
      model: SwiperPhysicsModel.RESPONSIVE_SPRING,
      response: 0.22,
      damping: 0.9,
      durationMs: 320,
      gestureRange: { min: 90, max: 120, expected: 120 },
      animationRange: { min: 60, max: 120, expected: 120 }
    };
  }

  static friction(): SwiperSyncProfile {
    return {
      name: 'Friction',
      model: SwiperPhysicsModel.FRICTION,
      response: 0,
      damping: 1,
      durationMs: 520,
      gestureRange: { min: 60, max: 120, expected: 120 },
      animationRange: { min: 24, max: 90, expected: 60 }
    };
  }
}
