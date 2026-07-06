import { AppTheme } from '../common/AppTheme';

@Component
export struct PulseGlow {
  @Prop @Watch('onPlayingChanged') isPlaying: boolean = false;
  glowColor: string = AppTheme.ACCENT;
  baseSize: number = 120;

  @State private pulseScale: number = 1.0;
  @State private glowOpacity: number = 0.12;

  private static readonly REST_SCALE: number = 1.0;
  private static readonly PEAK_SCALE: number = 1.16;
  private static readonly REST_OPACITY: number = 0.12;
  private static readonly PEAK_OPACITY: number = 0.32;
  private static readonly PERIOD_MS: number = 1300;

  aboutToAppear(): void {
    this.applyState();
  }

  private onPlayingChanged(): void {
    this.applyState();
  }

  private applyState(): void {
    this.pulseScale = this.isPlaying ? PulseGlow.PEAK_SCALE : PulseGlow.REST_SCALE;
    this.glowOpacity = this.isPlaying ? PulseGlow.PEAK_OPACITY : PulseGlow.REST_OPACITY;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(this.baseSize)
        .height(this.baseSize)
        .fill(this.glowColor)
        .opacity(this.glowOpacity)
        .blur(20)
        .scale({ x: this.pulseScale, y: this.pulseScale })
        .animation({
          duration: PulseGlow.PERIOD_MS,
          curve: Curve.EaseInOut,
          iterations: this.isPlaying ? -1 : 1,
          playMode: PlayMode.Alternate
        })

      Circle()
        .width(this.baseSize * 0.78)
        .height(this.baseSize * 0.78)
        .fillOpacity(0)
        .stroke(this.glowColor)
        .strokeWidth(1.5)
        .strokeOpacity(this.glowOpacity)
        .scale({ x: this.pulseScale, y: this.pulseScale })
        .animation({
          duration: PulseGlow.PERIOD_MS,
          curve: Curve.EaseInOut,
          iterations: this.isPlaying ? -1 : 1,
          playMode: PlayMode.Alternate
        })
    }
    .width(this.baseSize)
    .height(this.baseSize)
    .hitTestBehavior(HitTestMode.None)
  }
}
