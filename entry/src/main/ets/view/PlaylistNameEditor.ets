import { pointer } from '@kit.InputKit';
import { PlayerViewModel } from '../viewmodel/PlayerViewModel';
import { AppTheme } from '../common/AppTheme';

@Component
export struct PlaylistNameEditor {
  @ObjectLink vm: PlayerViewModel;
  contentWidth: number = 180;
  onClose?: () => void;

  private inputController: TextInputController = new TextInputController();

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

  private caretHome(): void {
    this.inputController.caretPosition(0);
  }

  private caretEnd(): void {
    this.inputController.caretPosition(this.vm.playlistName.length);
  }

  private selectAll(): void {
    this.inputController.setTextSelection(0, this.vm.playlistName.length);
  }

  private appendStarThenHome(): void {
    const decorated: string = `${this.vm.playlistName} ✦`;
    this.vm.setPlaylistName(decorated);
    this.inputController.caretPosition(0);
  }

  @Builder
  CaretPill(label: string, emphasize: boolean, onTap: () => void) {
    Button({ type: ButtonType.Capsule, stateEffect: true }) {
      Text(label)
        .fontSize(12)
        .fontWeight(FontWeight.Medium)
        .fontColor(emphasize ? this.vm.accent : AppTheme.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .height(36)
    .padding({ left: 6, right: 6 })
    .backgroundColor(AppTheme.CARD)
    .border(emphasize ? { width: 1, color: this.vm.accent } : { width: 0 })
    .hitTestBehavior(HitTestMode.Default)
    .onClick(() => {
      onTap();
    })
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left')).fontSize(16).fontColor([AppTheme.TEXT_PRIMARY])
        }
        .width(30).height(30)
        .backgroundColor(AppTheme.CARD)
        .onClick(() => {
          this.inputController.stopEditing();
          if (this.onClose !== undefined) {
            this.onClose();
          }
        })
        Blank()
        Text('Rename')
          .fontSize(15).fontWeight(FontWeight.Medium).fontColor(AppTheme.TEXT_PRIMARY)
        Blank()
        Row().width(30).height(30)
      }
      .width(this.contentWidth)
      .margin({ bottom: 6 })

      TextInput({
        text: this.vm.playlistName,
        placeholder: 'Playlist name',
        controller: this.inputController
      })
        .width(this.contentWidth)
        .height(40)
        .padding({ left: 18, right: 18 })
        .backgroundColor(AppTheme.CARD_STRONG)
        .borderRadius(20)
        .border({ width: 1, color: AppTheme.HAIRLINE })
        .placeholderColor(AppTheme.TEXT_TERTIARY)
        .placeholderFont({ size: 15 })
        .fontColor(AppTheme.TEXT_PRIMARY)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .caretColor(this.vm.accent)
        .selectedBackgroundColor(this.vm.accent)
        .maxLength(40)
        .enableKeyboardOnFocus(true)
        .onChange((value: string) => {
          this.vm.setPlaylistName(value);
        })
        .onFocus(() => {
          this.applyBeamCursor();
        })
        .onBlur(() => {
          this.restoreCursor();
        })
        .onSubmit((enterKey: EnterKeyType) => {
          this.inputController.stopEditing();
        })

      Row({ space: 8 }) {
        this.CaretPill('Home', false, () => {
          this.caretHome();
        })
        this.CaretPill('End', false, () => {
          this.caretEnd();
        })
      }
      .width(this.contentWidth)
      .margin({ top: 10 })

      Row({ space: 8 }) {
        this.CaretPill('Select all', false, () => {
          this.selectAll();
        })
        this.CaretPill('Append ✦', true, () => {
          this.appendStarThenHome();
        })
      }
      .width(this.contentWidth)
      .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
