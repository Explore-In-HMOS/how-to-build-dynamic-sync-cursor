import { CircleShape } from '@kit.ArkUI';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { DisplayGeometry } from '../service/DisplayGeometry';
import { SwiperSyncPresets } from '../service/SwiperSync';
import { MarqueeSyncPresets } from '../service/MarqueeSync';
import { AppTheme } from '../common/AppTheme';
import { ProgressRing } from '../view/ProgressRing';
import { PulseGlow } from '../view/PulseGlow';
import { AlbumRotor } from '../view/AlbumRotor';
import { AlbumArtSwiper } from '../view/AlbumArtSwiper';
import { TitleMarquee } from '../view/TitleMarquee';
import { TransportControls } from '../view/TransportControls';
import { AlbumDetailLoupe } from '../view/AlbumDetailLoupe';
import { SearchPanel } from '../view/SearchPanel';
import { PlaylistNameEditor } from '../view/PlaylistNameEditor';

enum AppScreen {
  NOW_PLAYING = 0,
  ALBUM_DETAIL = 1,
  SEARCH = 2,
  PLAYLIST = 3
}

@Entry
@Component
struct Index {
  @State private vm: PlayerViewModel = new PlayerViewModel();
  @State private screen: AppScreen = AppScreen.NOW_PLAYING;
  private geo: DisplayGeometry = DisplayGeometry.get();

  aboutToDisappear(): void {
    this.vm.dispose();
  }

  private diameter(): number {
    return this.geo.diameterVp;
  }

  private safe(): number {
    return this.geo.safeSquareVp;
  }

  @Builder
  NavButton(symbol: Resource, onTap: () => void) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph(symbol).fontSize(Math.max(15, this.safe() * 0.097)).fontColor([AppTheme.TEXT_PRIMARY])
    }
    .width(Math.max(32, this.safe() * 0.205))
    .height(Math.max(32, this.safe() * 0.205))
    .backgroundColor(AppTheme.CARD)
    .onClick(() => {
      onTap();
    })
  }

  @Builder
  NowPlaying() {
    Scroll() {
      Column() {
        Column() {
          Text(this.vm.playlistName)
            .fontSize(13).fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .maxLines(1).minFontSize(10).maxFontSize(13)
            .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Center)
            .constraintSize({ maxWidth: this.safe() * 0.82 })
            .margin({ bottom: 4 })

          Stack({ alignContent: Alignment.Center }) {
            PulseGlow({
              isPlaying: this.vm.isPlaying,
              glowColor: this.vm.accent,
              baseSize: this.safe() * 0.62
            })
            AlbumRotor({ vm: this.vm, discSize: this.safe() * 0.66 })
            AlbumArtSwiper({
              vm: this.vm,
              coverSize: this.safe() * 0.56,
              swiperWidth: this.diameter() * 0.9,
              profile: SwiperSyncPresets.spring(),
              onCoverLongPress: () => {
                this.screen = AppScreen.ALBUM_DETAIL;
              }
            })
          }
          .width(this.diameter())
          .height(this.safe() * 0.66)

          TitleMarquee({
            vm: this.vm,
            widthVp: this.safe() * 0.84,
            fontSizeFp: 17,
            profile: MarqueeSyncPresets.smooth()
          })
            .margin({ top: 6 })
          Text(this.vm.currentTrack.artist)
            .fontSize(13)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .maxLines(1).minFontSize(10).maxFontSize(13)
            .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Center)
            .constraintSize({ maxWidth: this.safe() * 0.82 })
            .margin({ top: 3 })
          Text(this.vm.currentTrack.album)
            .fontSize(11)
            .fontColor(AppTheme.TEXT_TERTIARY)
            .maxLines(1).minFontSize(9).maxFontSize(11)
            .heightAdaptivePolicy(TextHeightAdaptivePolicy.MIN_FONT_SIZE_FIRST)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Center)
            .constraintSize({ maxWidth: this.safe() * 0.82 })
            .margin({ top: 1 })
        }
        .width(this.diameter())
        .height(this.diameter())
        .padding({ left: this.geo.safeInsetVp, right: this.geo.safeInsetVp, top: 10, bottom: 10 })
        .justifyContent(FlexAlign.Center)

        Column() {
          TransportControls({ vm: this.vm, accent: this.vm.accent, safe: this.safe() })

          Row({ space: 16 }) {
            this.NavButton($r('sys.symbol.magnifyingglass'), () => {
              this.screen = AppScreen.SEARCH;
            })
            this.NavButton($r('sys.symbol.square_and_pencil'), () => {
              this.screen = AppScreen.PLAYLIST;
            })
          }
          .margin({ top: 10 })
        }
        .width(this.diameter())
        .height(this.diameter())
        .padding({ left: this.geo.safeInsetVp, right: this.geo.safeInsetVp })
        .justifyContent(FlexAlign.Center)
      }
      .width(this.diameter())
    }
    .width(this.diameter())
    .height(this.diameter())
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .enablePaging(true)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .radialGradient({
          center: ['50%', '50%'],
          radius: this.diameter() * 0.72,
          colors: [[AppTheme.BG_INNER, 0.0], [AppTheme.BG_OUTER, 1.0]]
        })

      if (this.screen === AppScreen.NOW_PLAYING) {
        ProgressRing({ vm: this.vm, diameter: this.diameter() - 6, strokeWidth: 6 })
      }

      if (this.screen === AppScreen.NOW_PLAYING) {
        this.NowPlaying()
      } else if (this.screen === AppScreen.ALBUM_DETAIL) {
        AlbumDetailLoupe({
          track: this.vm.currentTrack,
          artSize: this.safe() * 0.94,
          onClose: () => {
            this.screen = AppScreen.NOW_PLAYING;
          }
        })
      } else if (this.screen === AppScreen.SEARCH) {
        SearchPanel({
          vm: this.vm,
          contentWidth: this.safe(),
          onClose: () => {
            this.screen = AppScreen.NOW_PLAYING;
          }
        })
      } else {
        PlaylistNameEditor({
          vm: this.vm,
          contentWidth: this.safe(),
          onClose: () => {
            this.screen = AppScreen.NOW_PLAYING;
          }
        })
      }

      if (this.screen === AppScreen.NOW_PLAYING) {
        Column()
          .width('100%')
          .height('100%')
          .radialGradient({
            center: ['50%', '50%'],
            radius: this.diameter() * 0.5,
            colors: [['#00000000', 0.0], ['#00000000', 0.86], ['#73000000', 1.0]]
          })
          .hitTestBehavior(HitTestMode.None)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_OUTER)
    .clipShape(
      this.geo.isRound
        ? new CircleShape({ width: this.diameter(), height: this.diameter() })
            .position({
              x: (this.geo.widthVp - this.diameter()) / 2,
              y: (this.geo.heightVp - this.diameter()) / 2
            })
        : undefined
    )
  }
}
