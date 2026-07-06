import { UIContext } from '@kit.ArkUI';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { DynamicSyncHub } from '../service/DynamicSyncHub';
import { MarqueeSyncProfile, MarqueeSyncPresets } from '../service/MarqueeSync';
import { AppTheme } from '../common/AppTheme';

@Component
export struct TitleMarquee {
  @ObjectLink vm: PlayerViewModel;
  widthVp: number = 180;
  fontSizeFp: number = 17;
  profile: MarqueeSyncProfile = MarqueeSyncPresets.smooth();

  private readonly marqueeId: string = 'titleMarquee';
  private retryCount: number = 0;
  private retryTimer: number = -1;
  private disposed: boolean = false;
  private static readonly MAX_RETRIES: number = 8;
  private static readonly RETRY_DELAY_MS: number = 50;

  aboutToDisappear(): void {
    this.disposed = true;
    if (this.retryTimer !== -1) {
      clearTimeout(this.retryTimer);
      this.retryTimer = -1;
    }
    DynamicSyncHub.get().unbind(this.getUIContext(), this.marqueeId);
  }

  private scrolling(): boolean {
    return this.profile.pauseWhenPaused ? this.vm.isPlaying : true;
  }

  private bindSync(): void {
    if (this.disposed) {
      return;
    }
    const ui: UIContext = this.getUIContext();
    const ok: boolean = DynamicSyncHub.get().bindMarquee(ui, this.marqueeId, this.profile);
    if (!ok && this.retryCount < TitleMarquee.MAX_RETRIES) {
      this.retryCount++;
      this.retryTimer = setTimeout(() => {
        this.retryTimer = -1;
        this.bindSync();
      }, TitleMarquee.RETRY_DELAY_MS);
    }
  }

  build() {
    Marquee({
      start: this.scrolling(),
      step: this.profile.stepVp,
      loop: this.profile.loop,
      fromStart: this.profile.fromStart,
      src: this.vm.currentTrack.title
    })
      .id(this.marqueeId)
      .fontColor(AppTheme.TEXT_PRIMARY)
      .fontSize(this.fontSizeFp)
      .fontWeight(FontWeight.Medium)
      .width(this.widthVp)
      .height(this.fontSizeFp + 8)
      .onAppear(() => {
        this.disposed = false;
        this.retryCount = 0;
        this.bindSync();
      })
  }
}
