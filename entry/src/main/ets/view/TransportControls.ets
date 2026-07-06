import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { RepeatMode } from '../model/Track';
import { Track } from '../model/Track';
import { AppTheme } from '../common/AppTheme';

@Component
export struct TransportControls {
  @ObjectLink vm: PlayerViewModel;
  accent: string = AppTheme.ACCENT;
  safe: number = 165;

  private secDia(): number {
    return Math.max(30, this.safe * 0.2);
  }
  private secGlyph(): number {
    return Math.max(14, this.safe * 0.096);
  }
  private sideDia(): number {
    return Math.max(42, this.safe * 0.27);
  }
  private sideGlyph(): number {
    return Math.max(18, this.safe * 0.12);
  }
  private playDia(): number {
    return Math.max(56, this.safe * 0.36);
  }
  private playGlyph(): number {
    return Math.max(25, this.safe * 0.17);
  }
  private clockWidth(): number {
    return this.safe * 0.84;
  }

  @Builder
  CircleIcon(symbol: Resource, diameter: number, glyphSize: number, tint: ResourceColor, bg: ResourceColor,
    onTap: () => void) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph(symbol)
        .fontSize(glyphSize)
        .fontColor([tint])
    }
    .width(diameter)
    .height(diameter)
    .backgroundColor(bg)
    .onClick(() => {
      onTap();
    })
  }

  private repeatSymbol(): Resource {
    return this.vm.repeatMode === RepeatMode.ONE
      ? $r('sys.symbol.repeat_1')
      : $r('sys.symbol.repeat');
  }

  private repeatTint(): ResourceColor {
    return this.vm.repeatMode === RepeatMode.OFF ? AppTheme.TEXT_TERTIARY : this.accent;
  }

  private shuffleTint(): ResourceColor {
    return this.vm.shuffle ? this.accent : AppTheme.TEXT_TERTIARY;
  }

  build() {
    Column() {
      Row({ space: this.safe * 0.1 }) {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.shuffle')).fontSize(this.secGlyph()).fontColor([this.shuffleTint()])
        }
        .width(this.secDia()).height(this.secDia()).backgroundColor(AppTheme.CARD)
        .onClick(() => {
          this.vm.toggleShuffle();
        })
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph(this.repeatSymbol()).fontSize(this.secGlyph()).fontColor([this.repeatTint()])
        }
        .width(this.secDia()).height(this.secDia()).backgroundColor(AppTheme.CARD)
        .onClick(() => {
          this.vm.cycleRepeat();
        })
      }
      .margin({ bottom: 2 })

      Row({ space: this.safe * 0.06 }) {
        this.CircleIcon($r('sys.symbol.backward_end_fill'), this.sideDia(), this.sideGlyph(), AppTheme.TEXT_PRIMARY, AppTheme.CARD, () => {
          this.vm.previous();
        })
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph(this.vm.isPlaying ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
            .fontSize(this.playGlyph()).fontColor(['#FF101018'])
        }
        .width(this.playDia()).height(this.playDia()).backgroundColor(this.accent)
        .onClick(() => {
          this.vm.togglePlay();
        })
        this.CircleIcon($r('sys.symbol.forward_end_fill'), this.sideDia(), this.sideGlyph(), AppTheme.TEXT_PRIMARY, AppTheme.CARD, () => {
          this.vm.next();
        })
      }

      Row() {
        Text(Track.formatClock(this.vm.positionMs))
          .fontSize(10).fontColor(AppTheme.TEXT_SECONDARY)
        Blank()
        Text(Track.formatClock(this.vm.durationMs))
          .fontSize(10).fontColor(AppTheme.TEXT_TERTIARY)
      }
      .width(this.clockWidth())
      .margin({ top: 6 })

      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.speaker_wave_2_fill'))
          .fontSize(Math.max(12, this.safe * 0.078))
          .fontColor([AppTheme.TEXT_TERTIARY])
        Slider({ value: this.vm.volume, min: 0, max: 100, step: 1, style: SliderStyle.OutSet })
          .layoutWeight(1)
          .blockColor(AppTheme.TEXT_PRIMARY)
          .trackColor(AppTheme.CARD_STRONG)
          .selectedColor(this.accent)
          .trackThickness(4)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.vm.setVolume(value);
          })
      }
      .width(this.clockWidth())
      .margin({ top: 6 })
    }
    .alignItems(HorizontalAlign.Center)
  }
}
