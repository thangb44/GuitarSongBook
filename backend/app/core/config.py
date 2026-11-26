from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Guitar Songbook API"
    app_version: str = "1.0.0"
    api_prefix: str = "/api/v1"

    musicbrainz_base_url: str = "https://musicbrainz.org/ws/2"
    musicbrainz_contact_email: str

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()