import { Track } from '../model/Track';
import { AppTheme } from '../common/AppTheme';

@Component
export struct AlbumCover {
  track: Track = new Track('', '', '', '', 0, '#FF000000', '#FF000000', '#FFFFFFFF', 0, 0, '');
  coverSize: number = 120;
  detailed: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [[this.track.artStart, 0.0], [this.track.artEnd, 1.0]]
        })

      Circle()
        .width(this.coverSize * 0.92).height(this.coverSize * 0.92)
        .fillOpacity(0).stroke(AppTheme.HAIRLINE).strokeWidth(1)
      Circle()
        .width(this.coverSize * 0.64).height(this.coverSize * 0.64)
        .fillOpacity(0).stroke(AppTheme.HAIRLINE).strokeWidth(1)
      Circle()
        .width(this.coverSize * 0.38).height(this.coverSize * 0.38)
        .fillOpacity(0).stroke(AppTheme.HAIRLINE).strokeWidth(1)

      Column() {
        Text(this.track.monogram)
          .fontSize(this.coverSize * 0.34)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.TEXT_PRIMARY)
        if (!this.detailed) {
          Text(this.track.album)
            .fontSize(11)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 4 })
            .constraintSize({ maxWidth: this.coverSize * 0.86 })
        }
      }

      if (this.detailed) {
        Column() {
          Text(this.track.album)
            .fontSize(12).fontWeight(FontWeight.Medium).fontColor(AppTheme.TEXT_PRIMARY)
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${this.track.artist} · ${this.track.year} · ${this.track.bpm} BPM`)
            .fontSize(9).fontColor(AppTheme.TEXT_SECONDARY).margin({ top: 2 })
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.track.credits)
            .fontSize(7).lineHeight(9).fontColor(AppTheme.TEXT_TERTIARY)
            .maxLines(6).textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 3 })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding({ left: 10, right: 10, bottom: 10 })
        .position({ x: 0, y: this.coverSize * 0.5 })
        .height(this.coverSize * 0.5)
        .justifyContent(FlexAlign.End)
      }
    }
    .width(this.coverSize)
    .height(this.coverSize)
    .borderRadius(this.coverSize * 0.18)
    .clip(true)
    .shadow({ radius: 16, color: '#80000000', offsetX: 0, offsetY: 8 })
  }
}
