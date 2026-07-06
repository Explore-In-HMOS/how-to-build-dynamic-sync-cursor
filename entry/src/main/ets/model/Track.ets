export enum RepeatMode {
  OFF = 0,
  ALL = 1,
  ONE = 2
}

export enum PlaybackState {
  STOPPED = 0,
  PLAYING = 1,
  PAUSED = 2
}

@Observed
export class Track {
  readonly id: string;
  readonly title: string;
  readonly artist: string;
  readonly album: string;
  readonly durationMs: number;
  readonly artStart: string;
  readonly artEnd: string;
  readonly accent: string;
  readonly bpm: number;
  readonly year: number;
  readonly credits: string;

  constructor(
    id: string,
    title: string,
    artist: string,
    album: string,
    durationMs: number,
    artStart: string,
    artEnd: string,
    accent: string,
    bpm: number,
    year: number,
    credits: string
  ) {
    this.id = id;
    this.title = title;
    this.artist = artist;
    this.album = album;
    this.durationMs = durationMs;
    this.artStart = artStart;
    this.artEnd = artEnd;
    this.accent = accent;
    this.bpm = bpm;
    this.year = year;
    this.credits = credits;
  }

  static formatClock(ms: number): string {
    const totalSeconds: number = Math.max(0, Math.floor(ms / 1000));
    const minutes: number = Math.floor(totalSeconds / 60);
    const seconds: number = totalSeconds % 60;
    const ss: string = seconds < 10 ? `0${seconds}` : `${seconds}`;
    return `${minutes}:${ss}`;
  }

  get monogram(): string {
    return this.title.length > 0 ? this.title.substring(0, 1).toUpperCase() : '♪';
  }
}

export class MediaLibrary {
  static createDefaultQueue(): Track[] {
    return [
      new Track(
        't-001',
        'Aurora Borealis (Extended Midnight Mix)',
        'Polar Fields',
        'Northern Lights',
        242000,
        '#FF1B2A4A', '#FF0B7A75', '#FF35E0C8',
        124, 2023,
        'Written & produced by Polar Fields · Mixed at Glacier Studio · Mastered by H. Voss · Analog synths: Juno-106, Prophet-5 · Strings: Reykjavík Session Orchestra'
      ),
      new Track(
        't-002',
        'Velvet Circuitry',
        'Neon Atlas',
        'Static Bloom',
        198000,
        '#FF3A0CA3', '#FFF72585', '#FFFF6BCB',
        128, 2022,
        'All instruments by Neon Atlas · Vocoder: TR-808 chain · Recorded live to tape · Additional programming by M. Okonkwo · Artwork by Studio Halcyon'
      ),
      new Track(
        't-003',
        'Glass Harbour',
        'Tidewater',
        'Salt & Signal',
        273000,
        '#FF014F86', '#FF89C2D9', '#FFA9D6E5',
        96, 2024,
        'Field recordings from Bergen harbour · Piano: Steinway B · Engineered by L. Strand · Choir arranged by the composer · A Salt & Signal release'
      ),
      new Track(
        't-004',
        'Ember Throttle',
        'Redline Saints',
        'Combustion',
        211000,
        '#FF6A040F', '#FFF48C06', '#FFFFBA08',
        140, 2021,
        'Guitars: \'72 Les Paul through a Plexi stack · Drums tracked at Furnace Room · Produced by The Redline Saints · Mastered hot for the road'
      ),
      new Track(
        't-005',
        'Quiet Machines',
        'Hollow Coast',
        'Low Tide Frequencies',
        256000,
        '#FF22223B', '#FF4A4E69', '#FF9A8C98',
        72, 2020,
        'Ambient generative patches built in Max/MSP · Cello: A. Reyes · Mixed in immersive 7.1.4 · A meditation on stillness and tide'
      ),
      new Track(
        't-006',
        'Solar Parade',
        'Marigold Avenue',
        'Daybreak Boulevard',
        188000,
        '#FFB5179E', '#FF7209B7', '#FFF72585',
        118, 2025,
        'Horn section: The Avenue Brass · Recorded across three sunrise sessions · Produced by Marigold Avenue · For everyone who walks home at dawn'
      )
    ];
  }
}
