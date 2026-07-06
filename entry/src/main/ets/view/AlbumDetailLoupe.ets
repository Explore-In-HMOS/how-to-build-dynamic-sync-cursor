import { Magnifier } from '@kit.ArkUI';
import { Track } from '../model/Track';
import { AppTheme } from '../common/AppTheme';
import { AlbumCover } from './AlbumCover';

@Component
export struct AlbumDetailLoupe {
  track: Track = new Track('', 'Unknown', 'Unknown', 'Unknown', 0, '#FF222233', '#FF111122', '#FF35E0C8', 0, 0, '');
  artSize: number = 168;
  onClose?: () => void;

  private magnifier: Magnifier | undefined = undefined;
  private readonly artId: string = 'loupeArtSurface';
  @State private loupeActive: boolean = false;

  aboutToAppear(): void {
    try {
      this.magnifier = this.getUIContext().getMagnifier();
      this.magnifier.bind(this.artId);
    } catch (err) {
      this.magnifier = undefined;
    }
  }

  aboutToDisappear(): void {
    try {
      if (this.magnifier !== undefined) {
        this.magnifier.show(-1, -1);
        this.magnifier.unbind();
      }
    } catch (err) {
    }
    this.magnifier = undefined;
  }

  private showLoupeXY(x: number, y: number): void {
    if (this.magnifier === undefined) {
      return;
    }
    try {
      this.magnifier.show(x, y);
    } catch (err) {
    }
  }

  private hideLoupe(): void {
    if (this.magnifier === undefined) {
      return;
    }
    try {
      this.magnifier.show(-1, -1);
    } catch (err) {
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%').height('100%')
        .backgroundColor(AppTheme.BG_OUTER)

      Column() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(16).fontColor([AppTheme.TEXT_PRIMARY])
        }
        .width(32).height(32)
        .backgroundColor(AppTheme.CARD)
        .margin({ bottom: 8 })
        .onClick(() => {
          if (this.onClose !== undefined) {
            this.onClose();
          }
        })

        Stack({ alignContent: Alignment.Center }) {
          AlbumCover({ track: this.track, coverSize: this.artSize, detailed: true })
        }
        .id(this.artId)
        .width(this.artSize)
        .height(this.artSize)
        .gesture(
          LongPressGesture({ repeat: false, duration: 250 })
            .onAction((event: GestureEvent) => {
              this.loupeActive = true;
              const fingers: FingerInfo[] = event.fingerList;
              if (fingers.length > 0) {
                this.showLoupeXY(fingers[0].localX, fingers[0].localY);
              }
            })
        )
        .onTouch((event: TouchEvent) => {
          if (!this.loupeActive) {
            return;
          }
          if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.loupeActive = false;
            this.hideLoupe();
            return;
          }
          if (event.touches.length === 0) {
            return;
          }
          const t: TouchObject = event.touches[0];
          if (event.type === TouchType.Move) {
            this.showLoupeXY(t.x, t.y);
          }
        })

        Text(this.loupeActive ? 'Move to inspect the liner notes' : 'Press & hold the cover to magnify')
          .fontSize(11)
          .fontColor(this.loupeActive ? this.track.accent : AppTheme.TEXT_SECONDARY)
          .margin({ top: 10 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.track.title)
          .fontSize(13).fontWeight(FontWeight.Medium).fontColor(AppTheme.TEXT_PRIMARY)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 6 })
          .constraintSize({ maxWidth: this.artSize })
        Text(`${this.track.artist} — ${this.track.album}`)
          .fontSize(10).fontColor(AppTheme.TEXT_TERTIARY)
          .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          .constraintSize({ maxWidth: this.artSize })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
