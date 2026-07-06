import { Track, RepeatMode, PlaybackState, MediaLibrary } from '../model/Track';

@Observed
export class PlayerViewModel {
  tracks: Track[] = MediaLibrary.createDefaultQueue();
  currentIndex: number = 0;
  positionMs: number = 0;
  isPlaying: boolean = false;
  repeatMode: RepeatMode = RepeatMode.ALL;
  shuffle: boolean = false;

  playlistName: string = 'Midnight Drive';
  searchQuery: string = '';
  volume: number = 70;

  private static readonly TICK_MS: number = 120;
  private static readonly PREV_RESTART_THRESHOLD_MS: number = 3000;

  private tickHandle: number = -1;
  private lastTickMs: number = 0;

  get currentTrack(): Track {
    return this.tracks[this.currentIndex];
  }

  get durationMs(): number {
    return this.currentTrack.durationMs;
  }

  get progress(): number {
    const dur: number = this.durationMs;
    if (dur <= 0) {
      return 0;
    }
    return Math.min(1, Math.max(0, this.positionMs / dur));
  }

  get playbackState(): PlaybackState {
    if (this.isPlaying) {
      return PlaybackState.PLAYING;
    }
    return this.positionMs > 0 ? PlaybackState.PAUSED : PlaybackState.STOPPED;
  }

  get accent(): string {
    return this.currentTrack.accent;
  }

  togglePlay(): void {
    if (this.isPlaying) {
      this.pause();
    } else {
      this.play();
    }
  }

  play(): void {
    if (this.tracks.length === 0) {
      return;
    }
    this.isPlaying = true;
    this.startTick();
  }

  pause(): void {
    this.isPlaying = false;
    this.stopTick();
  }

  next(): void {
    this.advance(false);
  }

  previous(): void {
    if (this.positionMs > PlayerViewModel.PREV_RESTART_THRESHOLD_MS) {
      this.positionMs = 0;
      this.lastTickMs = Date.now();
      return;
    }
    const len: number = this.tracks.length;
    if (len === 0) {
      return;
    }
    let prevIdx: number = this.currentIndex - 1;
    if (prevIdx < 0) {
      prevIdx = len - 1;
    }
    this.currentIndex = prevIdx;
    this.positionMs = 0;
    this.lastTickMs = Date.now();
    this.restartTick();
  }

  cueIndex(index: number): void {
    if (index < 0 || index >= this.tracks.length || index === this.currentIndex) {
      return;
    }
    this.currentIndex = index;
    this.positionMs = 0;
    this.lastTickMs = Date.now();
  }

  selectIndex(index: number): void {
    if (index < 0 || index >= this.tracks.length) {
      return;
    }
    this.currentIndex = index;
    this.positionMs = 0;
    this.play();
  }

  seekToFraction(fraction: number): void {
    const clamped: number = Math.min(1, Math.max(0, fraction));
    this.positionMs = Math.round(clamped * this.durationMs);
    this.lastTickMs = Date.now();
  }

  cycleRepeat(): void {
    if (this.repeatMode === RepeatMode.OFF) {
      this.repeatMode = RepeatMode.ALL;
    } else if (this.repeatMode === RepeatMode.ALL) {
      this.repeatMode = RepeatMode.ONE;
    } else {
      this.repeatMode = RepeatMode.OFF;
    }
  }

  toggleShuffle(): void {
    this.shuffle = !this.shuffle;
  }

  setSearchQuery(query: string): void {
    this.searchQuery = query;
  }

  searchResults(): Track[] {
    const q: string = this.searchQuery.trim().toLowerCase();
    if (q.length === 0) {
      return this.tracks;
    }
    return this.tracks.filter((t: Track) =>
      t.title.toLowerCase().includes(q) ||
      t.artist.toLowerCase().includes(q) ||
      t.album.toLowerCase().includes(q)
    );
  }

  setPlaylistName(name: string): void {
    this.playlistName = name;
  }

  setVolume(value: number): void {
    this.volume = Math.min(100, Math.max(0, Math.round(value)));
  }

  dispose(): void {
    this.stopTick();
  }

  private advance(auto: boolean): void {
    const len: number = this.tracks.length;
    if (len === 0) {
      return;
    }

    if (auto && this.repeatMode === RepeatMode.ONE) {
      this.positionMs = 0;
      this.lastTickMs = Date.now();
      this.restartTick();
      return;
    }

    let nextIdx: number;
    if (this.shuffle && len > 1) {
      nextIdx = this.pickShuffleIndex();
    } else {
      nextIdx = this.currentIndex + 1;
      if (nextIdx >= len) {
        if (auto && this.repeatMode === RepeatMode.OFF) {
          this.currentIndex = len - 1;
          this.positionMs = this.durationMs;
          this.pause();
          return;
        }
        nextIdx = 0;
      }
    }

    this.currentIndex = nextIdx;
    this.positionMs = 0;
    this.lastTickMs = Date.now();
    this.restartTick();
  }


  private seed = 12345;
  private nextRandom(): number {
    this.seed = (this.seed * 9301 + 49297) % 233280;
    return this.seed / 233280;
  }

  private pickShuffleIndex(): number {
    const len = this.tracks.length;
    let candidate = this.currentIndex;
    while (candidate === this.currentIndex) {
      candidate = Math.floor(this.nextRandom() * len);
    }
    return candidate;
  }

  private startTick(): void {
    this.stopTick();
    this.lastTickMs = Date.now();
    this.tickHandle = setInterval(() => {
      this.onTick();
    }, PlayerViewModel.TICK_MS);
  }

  private stopTick(): void {
    if (this.tickHandle !== -1) {
      clearInterval(this.tickHandle);
      this.tickHandle = -1;
    }
  }

  private restartTick(): void {
    if (this.isPlaying) {
      this.startTick();
    }
  }

  private onTick(): void {
    if (!this.isPlaying) {
      return;
    }
    const now: number = Date.now();
    const delta: number = now - this.lastTickMs;
    this.lastTickMs = now;

    const dur: number = this.durationMs;
    const projected: number = this.positionMs + delta;
    if (projected >= dur) {
      this.positionMs = dur;
      this.advance(true);
    } else {
      this.positionMs = projected;
    }
  }
}
