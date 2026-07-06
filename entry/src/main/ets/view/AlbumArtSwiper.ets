import { UIContext, curves } from '@kit.ArkUI';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { DynamicSyncHub } from '../service/DynamicSyncHub';
import { SwiperSyncProfile, SwiperSyncPresets, SwiperPhysicsModel } from '../service/SwiperSync';
import { Track } from '../model/Track';
import { AlbumCover } from './AlbumCover';

@Component
export struct AlbumArtSwiper {
  @ObjectLink vm: PlayerViewModel;
  coverSize: number = 120;
  swiperWidth: number = 200;
  profile: SwiperSyncProfile = SwiperSyncPresets.spring();
  onCoverLongPress?: () => void;

  @State private itemScale: number[] = [];
  @State private itemOpacity: number[] = [];

  private readonly swiperId: string = 'albumArtSwiper';
  private retryCount: number = 0;
  private retryTimer: number = -1;
  private disposed: boolean = false;
  private static readonly MAX_RETRIES: number = 8;
  private static readonly RETRY_DELAY_MS: number = 50;
  private static readonly SCALE_FALLOFF: number = 0.18;
  private static readonly OPACITY_FALLOFF: number = 0.45;

  aboutToAppear(): void {
    const n: number = this.vm.tracks.length;
    this.itemScale = new Array<number>(n).fill(1);
    this.itemOpacity = new Array<number>(n).fill(1);
  }

  aboutToDisappear(): void {
    this.disposed = true;
    if (this.retryTimer !== -1) {
      clearTimeout(this.retryTimer);
      this.retryTimer = -1;
    }
    DynamicSyncHub.get().unbind(this.getUIContext(), this.swiperId);
  }

  private settleCurve(): Curve | ICurve | string {
    if (this.profile.model === SwiperPhysicsModel.FRICTION) {
      return Curve.Friction;
    }
    return curves.springMotion(this.profile.response, this.profile.damping);
  }

  private bindSync(): void {
    if (this.disposed) {
      return;
    }
    const ui: UIContext = this.getUIContext();
    const ok: boolean = DynamicSyncHub.get().bindSwiper(ui, this.swiperId, this.profile);
    if (!ok && this.retryCount < AlbumArtSwiper.MAX_RETRIES) {
      this.retryCount++;
      this.retryTimer = setTimeout(() => {
        this.retryTimer = -1;
        this.bindSync();
      }, AlbumArtSwiper.RETRY_DELAY_MS);
    }
  }

  private scaleFor(index: number): number {
    const s: number | undefined = this.itemScale[index];
    return s === undefined ? 1 : s;
  }

  private opacityFor(index: number): number {
    const o: number | undefined = this.itemOpacity[index];
    return o === undefined ? 1 : o;
  }

  build() {
    Swiper() {
      ForEach(this.vm.tracks, (track: Track, index: number) => {
        Stack({ alignContent: Alignment.Center }) {
          AlbumCover({ track: track, coverSize: this.coverSize, detailed: false })
        }
        .width('100%')
        .height('100%')
        .scale({ x: this.scaleFor(index), y: this.scaleFor(index) })
        .opacity(this.opacityFor(index))
        .gesture(
          LongPressGesture({ repeat: false, duration: 350 })
            .onAction(() => {
              if (this.onCoverLongPress !== undefined) {
                this.onCoverLongPress();
              }
            })
        )
      }, (track: Track, index: number ) => track.title)
    }
    .id(this.swiperId)
    .index(this.vm.currentIndex)
    .loop(true)
    .autoPlay(false)
    .displayCount(1)
    .prevMargin(18)
    .nextMargin(18)
    .itemSpace(10)
    .indicator(false)
    .duration(this.profile.durationMs)
    .curve(this.settleCurve())
    .width(this.swiperWidth)
    .height(this.coverSize + 24)
    .onChange((index: number) => {
      this.vm.cueIndex(index);
    })
    .onContentDidScroll((selectedIndex: number, index: number, position: number, mainAxisLength: number) => {
      const t: number = Math.min(Math.abs(position), 1);
      const nextScale: number[] = this.itemScale.slice();
      const nextOpacity: number[] = this.itemOpacity.slice();
      nextScale[index] = 1 - AlbumArtSwiper.SCALE_FALLOFF * t;
      nextOpacity[index] = 1 - AlbumArtSwiper.OPACITY_FALLOFF * t;
      this.itemScale = nextScale;
      this.itemOpacity = nextOpacity;
    })
    .onAppear(() => {
      this.disposed = false;
      this.retryCount = 0;
      this.bindSync();
    })
  }
}
