
from fastapi import APIRouter, HTTPException, Query

from app.schemas.song import SongSearchResponse
from app.services.song_search_service import song_search_service

router = APIRouter(prefix="/search", tags=["Song Search"])


@router.get("", response_model=SongSearchResponse)
async def search_songs(
    q: str = Query(..., min_length=2, max_length=100),
    artist: str | None = Query(default=None, max_length=100),
    limit: int = Query(default=20, ge=1, le=20),
):
    try:
        return await song_search_service.search_songs(
            query=q,
            artist=artist,
            limit=limit,
        )

    except RuntimeError as exc:
        raise HTTPException(
            status_code=502,
            detail=str(exc),
        ) from exc
