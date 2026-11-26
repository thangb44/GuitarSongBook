import unittest

from app.integrations.musicbrainz import MusicBrainzClient


class MusicBrainzQueryTests(unittest.TestCase):
    def test_partial_search_is_case_insensitive(self):
        lowercase_query = MusicBrainzClient._build_search_query("ed shee")
        mixed_case_query = MusicBrainzClient._build_search_query("Ed Shee")
        uppercase_query = MusicBrainzClient._build_search_query("ED SHEE")

        self.assertEqual(lowercase_query, mixed_case_query)
        self.assertEqual(lowercase_query, uppercase_query)
        self.assertEqual(
            lowercase_query,
            "(recording:ed* AND recording:shee*) "
            "OR (artist:ed* AND artist:shee*)",
        )

    def test_artist_filter_is_case_insensitive_and_prefix_matched(self):
        lowercase_query = MusicBrainzClient._build_search_query(
            "perf",
            artist="ed shee",
        )
        uppercase_query = MusicBrainzClient._build_search_query(
            "PERF",
            artist="ED SHEE",
        )

        self.assertEqual(lowercase_query, uppercase_query)
        self.assertEqual(
            lowercase_query,
            "(recording:perf*) AND (artist:ed* AND artist:shee*)",
        )
