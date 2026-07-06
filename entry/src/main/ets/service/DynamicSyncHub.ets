import { UIContext, SwiperDynamicSyncScene, SwiperDynamicSyncSceneType,
  MarqueeDynamicSyncScene, MarqueeDynamicSyncSceneType } from '@kit.ArkUI';
import { SwiperSyncProfile } from './SwiperSync';
import { MarqueeSyncProfile } from './MarqueeSync';

interface SwiperRegistration {
  ui: UIContext;
  id: string;
  profile: SwiperSyncProfile;
}

interface MarqueeRegistration {
  ui: UIContext;
  id: string;
  profile: MarqueeSyncProfile;
}

export class DynamicSyncHub {
  private static instance: DynamicSyncHub | undefined = undefined;

  private master: ExpectedFrameRateRange = { min: 30, max: 120, expected: 120 };

  private swiperRegs: SwiperRegistration[] = [];
  private marqueeRegs: MarqueeRegistration[] = [];

  static get(): DynamicSyncHub {
    if (DynamicSyncHub.instance === undefined) {
      DynamicSyncHub.instance = new DynamicSyncHub();
    }
    return DynamicSyncHub.instance;
  }

  getMaster(): ExpectedFrameRateRange {
    return this.master;
  }

  setMaster(range: ExpectedFrameRateRange): void {
    this.master = DynamicSyncHub.sanitize(range);
    this.reapplyAll();
  }

  bindSwiper(ui: UIContext, id: string, profile: SwiperSyncProfile): boolean {
    this.swiperRegs = this.swiperRegs.filter((r: SwiperRegistration) => !(r.ui === ui && r.id === id));
    this.swiperRegs.push({ ui, id, profile });
    return this.applySwiper(ui, id, profile);
  }

  bindMarquee(ui: UIContext, id: string, profile: MarqueeSyncProfile): boolean {
    this.marqueeRegs = this.marqueeRegs.filter((r: MarqueeRegistration) => !(r.ui === ui && r.id === id));
    this.marqueeRegs.push({ ui, id, profile });
    return this.applyMarquee(ui, id, profile);
  }

  unbind(ui: UIContext, id: string): void {
    this.swiperRegs = this.swiperRegs.filter((r: SwiperRegistration) => !(r.ui === ui && r.id === id));
    this.marqueeRegs = this.marqueeRegs.filter((r: MarqueeRegistration) => !(r.ui === ui && r.id === id));
  }

  private applySwiper(ui: UIContext, id: string, profile: SwiperSyncProfile): boolean {
    try {
      const scenes: Array<SwiperDynamicSyncScene> =
        ui.requireDynamicSyncScene(id) as Array<SwiperDynamicSyncScene>;
      if (scenes === undefined || scenes.length === 0) {
        return false;
      }
      for (const scene of scenes) {
        if (scene.type === SwiperDynamicSyncSceneType.GESTURE) {
          scene.setFrameRateRange(this.clampToMaster(profile.gestureRange));
        } else {
          scene.setFrameRateRange(this.clampToMaster(profile.animationRange));
        }
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  private applyMarquee(ui: UIContext, id: string, profile: MarqueeSyncProfile): boolean {
    try {
      const scenes: Array<MarqueeDynamicSyncScene> =
        ui.requireDynamicSyncScene(id) as Array<MarqueeDynamicSyncScene>;
      if (scenes === undefined || scenes.length === 0) {
        return false;
      }
      for (const scene of scenes) {
        if (scene.type === MarqueeDynamicSyncSceneType.ANIMATION) {
          scene.setFrameRateRange(this.clampToMaster(profile.animationRange));
        }
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  private reapplyAll(): void {
    for (const r of this.swiperRegs) {
      this.applySwiper(r.ui, r.id, r.profile);
    }
    for (const r of this.marqueeRegs) {
      this.applyMarquee(r.ui, r.id, r.profile);
    }
  }

  private clampToMaster(range: ExpectedFrameRateRange): ExpectedFrameRateRange {
    const safe: ExpectedFrameRateRange = DynamicSyncHub.sanitize(range);
    const max: number = Math.min(safe.max, this.master.max);
    const min: number = Math.min(safe.min, max);
    const expected: number = Math.min(safe.expected, this.master.expected, max);
    return { min, max, expected: Math.max(expected, min) };
  }

  private static sanitize(range: ExpectedFrameRateRange): ExpectedFrameRateRange {
    const max: number = Math.max(0, range.max);
    const min: number = Math.min(Math.max(0, range.min), max);
    const expected: number = Math.min(Math.max(range.expected, min), max);
    return { min, max, expected };
  }
}
