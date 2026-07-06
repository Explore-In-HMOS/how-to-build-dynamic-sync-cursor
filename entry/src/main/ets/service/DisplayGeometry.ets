import { display } from '@kit.ArkUI';

export class DisplayGeometry {
  private static instance: DisplayGeometry | undefined = undefined;

  widthVp: number = 233;
  heightVp: number = 233;
  diameterVp: number = 233;
  radiusVp: number = 116.5;
  safeSquareVp: number = 164;
  safeInsetVp: number = 34;
  isRound: boolean = true;

  private constructor() {
    this.refresh();
  }

  static get(): DisplayGeometry {
    if (DisplayGeometry.instance === undefined) {
      DisplayGeometry.instance = new DisplayGeometry();
    }
    return DisplayGeometry.instance;
  }

  refresh(): void {
    try {
      const d: display.Display = display.getDefaultDisplaySync();
      const density: number = d.densityPixels > 0 ? d.densityPixels : 1;

      const wVp: number = d.width / density;
      const hVp: number = d.height / density;
      this.widthVp = wVp;
      this.heightVp = hVp;
      this.diameterVp = Math.min(wVp, hVp);
      this.radiusVp = this.diameterVp / 2;

      this.isRound = DisplayGeometry.detectRound(d, wVp, hVp);
    } catch (err) {
    }

    this.safeSquareVp = this.diameterVp / Math.SQRT2;
    this.safeInsetVp = (this.diameterVp * (1 - 1 / Math.SQRT2)) / 2;
  }

  private static detectRound(d: display.Display, wVp: number, hVp: number): boolean {
    if (d.screenShape !== undefined) {
      return d.screenShape === display.ScreenShape.ROUND;
    }
    const longSide: number = Math.max(wVp, hVp);
    const shortSide: number = Math.min(wVp, hVp);
    const aspect: number = shortSide > 0 ? longSide / shortSide : 1;
    return aspect <= 1.05;
  }
}
