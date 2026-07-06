import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { AppTheme } from '../common/AppTheme';

@Component
export struct ProgressRing {
  @ObjectLink vm: PlayerViewModel;
  diameter: number = 220;
  strokeWidth: number = 6;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(this.diameter)
        .height(this.diameter)
        .fillOpacity(0)
        .stroke(AppTheme.TRACK_DIM)
        .strokeWidth(this.strokeWidth)

      Progress({
        value: Math.round(this.vm.progress * 1000),
        total: 1000,
        type: ProgressType.Ring
      })
        .width(this.diameter)
        .height(this.diameter)
        .color(this.vm.accent)
        .style({ strokeWidth: this.strokeWidth, enableSmoothEffect: true })
    }
    .width(this.diameter)
    .height(this.diameter)
  }
}
