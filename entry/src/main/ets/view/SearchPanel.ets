import { pointer } from '@kit.InputKit';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { Track } from '../model/Track';
import { AppTheme } from '../common/AppTheme';

@Component
export struct SearchPanel {
  @ObjectLink vm: PlayerViewModel;
  contentWidth: number = 180;
  onClose?: () => void;

  private searchController: SearchController = new SearchController();

  private applyBeamCursor(): void {
    try {
      if (canIUse('SystemCapability.MultimodalInput.Input.Pointer')) {
        this.getUIContext().getCursorController().setCursor(pointer.PointerStyle.TEXT_CURSOR);
      }
    } catch (err) {
    }
  }

  private restoreCursor(): void {
    try {
      this.getUIContext().getCursorController().restoreDefault();
    } catch (err) {
    }
  }

  private indexOfResult(track: Track): number {
    return this.vm.tracks.findIndex((t: Track) => t.id === track.id);
  }

  private vInset(): number {
    return Math.max(14, this.contentWidth * 0.21);
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(15).fontColor([AppTheme.TEXT_PRIMARY])
        }
        .width(30).height(30)
        .flexShrink(0)
        .backgroundColor(AppTheme.CARD)
        .onClick(() => {
          this.searchController.stopEditing();
          if (this.onClose !== undefined) {
            this.onClose();
          }
        })

        Search({
          value: this.vm.searchQuery,
          placeholder: 'Search songs',
          controller: this.searchController
        })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(AppTheme.CARD_STRONG)
          .borderRadius(20)
          .placeholderColor(AppTheme.TEXT_TERTIARY)
          .fontColor(AppTheme.TEXT_PRIMARY)
          .caretStyle({ color: this.vm.accent })
          .onChange((value: string) => {
            this.vm.setSearchQuery(value);
          })
          .onFocus(() => {
            this.applyBeamCursor();
          })
          .onBlur(() => {
            this.restoreCursor();
          })
          .onSubmit((value: string) => {
            this.searchController.stopEditing();
          })
      }
      .width(this.contentWidth)
      .margin({ bottom: 10 })

      List({ space: 8 }) {
        ForEach(this.vm.searchResults(), (track: Track) => {
          ListItem() {
            Row({ space: 10 }) {
              Column() {
                Text(track.title)
                  .fontSize(13).fontColor(AppTheme.TEXT_PRIMARY)
                  .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(track.artist)
                  .fontSize(11).fontColor(AppTheme.TEXT_TERTIARY)
                  .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 1 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              SymbolGlyph($r('sys.symbol.play_fill')).fontSize(15).fontColor([track.accent])
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 9, bottom: 9 })
            .backgroundColor(AppTheme.CARD)
            .borderRadius(16)
            .onClick(() => {
              const idx: number = this.indexOfResult(track);
              if (idx >= 0) {
                this.searchController.stopEditing();
                this.vm.selectIndex(idx);
                if (this.onClose !== undefined) {
                  this.onClose();
                }
              }
            })
          }
        }, (track: Track) => track.id)
      }
      .layoutWeight(1)
      .width(this.contentWidth)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .fadingEdge(true)
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.vInset(), bottom: this.vInset() })
    .alignItems(HorizontalAlign.Center)
  }
}
