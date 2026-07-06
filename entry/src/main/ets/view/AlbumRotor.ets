import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { DynamicSyncHub } from '../service/DynamicSyncHub';
import { AppTheme } from '../common/AppTheme';

@Component
export struct AlbumRotor {
  @ObjectLink vm: PlayerViewModel;
  discSize: number = 150;

  private static readonly TURNS_PER_TRACK: number = 8;

  private frameHint(): ExpectedFrameRateRange {
    return DynamicSyncHub.get().getMaster();
  }

  private angle(): number {
    return this.vm.progress * 360 * AlbumRotor.TURNS_PER_TRACK;
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(this.discSize).height(this.discSize)
        .fill('#FF0C0C12')

      Circle().width(this.discSize * 0.86).height(this.discSize * 0.86)
        .fillOpacity(0).stroke(AppTheme.HAIRLINE).strokeWidth(1)
      Circle().width(this.discSize * 0.66).height(this.discSize * 0.66)
        .fillOpacity(0).stroke(AppTheme.HAIRLINE).strokeWidth(1)
      Circle().width(this.discSize * 0.46).height(this.discSize * 0.46)
        .fillOpacity(0).stroke(AppTheme.HAIRLINE).strokeWidth(1)

      Circle().width(this.discSize * 0.3).height(this.discSize * 0.3)
        .fill(this.vm.accent).fillOpacity(0.92)
      Circle().width(this.discSize * 0.05).height(this.discSize * 0.05)
        .fill(AppTheme.BG_OUTER)

      Circle().width(this.discSize * 0.06).height(this.discSize * 0.06)
        .fill(AppTheme.TEXT_PRIMARY)
        .offset({ x: 0, y: -this.discSize * 0.38 })
    }
    .width(this.discSize)
    .height(this.discSize)
    .rotate({ angle: this.angle(), z: 1 })
    .animation({
      duration: 140,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
      expectedFrameRateRange: this.frameHint()
    })
    .opacity(0.9)
    .hitTestBehavior(HitTestMode.None)
  }
}
