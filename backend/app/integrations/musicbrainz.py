
import asyncio
import time

import httpx

from app.core.config import settings


class MusicBrainzClient:
    def __init__(self):
        self.base_url = settings.musicbrainz_base_url
        self.user_agent = (
            f"GuitarSongbook/{settings.app_version} "
            f"(mailto:{settings.musicbrainz_contact_email})"
        )

        self._lock = asyncio.Lock()
        self._last_request_time = 0.0

    async def _wait_for_rate_limit(self):
        # MusicBrainz allows at most one request per second.
        async with self._lock:
            elapsed = time.monotonic() - self._last_request_time
            wait_time = max(0.0, 1.0 - elapsed)

            if wait_time > 0:
                await asyncio.sleep(wait_time)

            self._last_request_time = time.monotonic()

    @staticmethod
    def _escape_lucene(value: str) -> str:
        special_chars = r'+-&|!(){}[]^"~*?:\/'

        escaped = ""

        for char in value:
            if char in special_chars:
                escaped += "\\"
            escaped += char

        return escaped

    @classmethod
    def _field_prefix_query(cls, field: str, value: str) -> str:
        terms = [
            f"{field}:{cls._escape_lucene(term)}*"
            for term in value.casefold().split()
        ]
        return " AND ".join(terms)

    @classmethod
    def _build_search_query(cls, query: str, artist: str | None = None) -> str:
        recording_query = cls._field_prefix_query("recording", query)

        if artist:
            artist_query = cls._field_prefix_query("artist", artist)
            return f"({recording_query}) AND ({artist_query})"

        artist_query = cls._field_prefix_query("artist", query)
        return f"({recording_query}) OR ({artist_query})"

    async def search_recordings(
        self,
        query: str,
        artist: str | None = None,
        limit: int = 20,
    ) -> dict:
        params = {
            "query": self._build_search_query(query, artist),
            "fmt": "json",
            "limit": limit,
        }

        headers = {
            "User-Agent": self.user_agent,
            "Accept": "application/json",
        }

        await self._wait_for_rate_limit()

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                response = await client.get(
                    f"{self.base_url}/recording",
                    params=params,
                    headers=headers,
                )

                response.raise_for_status()

                return response.json()

        except httpx.HTTPStatusError as exc:
            raise RuntimeError(
                f"MusicBrainz returned HTTP {exc.response.status_code}"
            ) from exc

        except httpx.RequestError as exc:
            raise RuntimeError(
                "Unable to connect to MusicBrainz"
            ) from exc


musicbrainz_client = MusicBrainzClient()
