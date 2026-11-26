
from app.integrations.musicbrainz import musicbrainz_client
from app.schemas.song import Song, SongSearchResponse


class SongSearchService:

    @staticmethod
    def _map_recording(recording: dict) -> Song:
        artist_credit = recording.get("artist-credit", [])

        artist_names = []

        for credit in artist_credit:
            if isinstance(credit, dict):
                artist = credit.get("artist", {})
                name = artist.get("name") or credit.get("name")

                if name:
                    artist_names.append(name)

        releases = recording.get("releases", [])

        album = None

        if releases:
            album = releases[0].get("title")

        return Song(
            id=recording["id"],
            title=recording["title"],
            artist=", ".join(artist_names) or "Unknown Artist",
            album=album,
            duration_ms=recording.get("length"),
        )

    async def search_songs(
        self,
        query: str,
        artist: str | None = None,
        limit: int = 20,
    ) -> SongSearchResponse:

        data = await musicbrainz_client.search_recordings(
            query=query,
            artist=artist,
            limit=limit,
        )

        recordings = data.get("recordings", [])

        songs = [
            self._map_recording(recording)
            for recording in recordings
            if recording.get("id") and recording.get("title")
        ]

        return SongSearchResponse(
            results=songs,
            total=data.get("count", len(songs)),
        )


song_search_service = SongSearchService()
