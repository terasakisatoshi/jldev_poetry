"""Smoke coverage for the image dependency used by plotting/notebooks."""

from io import BytesIO

import pytest
from PIL import Image


@pytest.mark.parametrize("image_format", ["PNG", "JPEG", "GIF", "TIFF"])
def test_image_roundtrip_and_thumbnail(image_format):
    data = BytesIO()
    Image.new("RGB", (32, 24), "red").save(data, format=image_format)
    data.seek(0)
    with Image.open(data) as image:
        image.load()
        assert image.size == (32, 24)
        image.thumbnail((8, 8))
        assert image.size == (8, 6)
