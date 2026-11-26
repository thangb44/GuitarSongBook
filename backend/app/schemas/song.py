from pydantic import BaseModel


class Song(BaseModel):
    id: str
    title: str
    artist: str
    album: str | None = None
    duration_ms: int | None = None
    provider: str = "musicbrainz"


class SongSearchResponse(BaseModel):
    results: list[Song]
    total: int